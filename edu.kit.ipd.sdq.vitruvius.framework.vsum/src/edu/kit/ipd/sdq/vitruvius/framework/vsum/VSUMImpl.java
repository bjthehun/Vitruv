package edu.kit.ipd.sdq.vitruvius.framework.vsum;

import java.io.IOException;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.Callable;

import org.apache.log4j.Logger;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.transaction.TransactionalEditingDomain;

import edu.kit.ipd.sdq.vitruvius.framework.contracts.datatypes.CorrespondenceModel;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.datatypes.Mapping;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.datatypes.Metamodel;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.datatypes.ModelInstance;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.datatypes.TUID;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.datatypes.VURI;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.interfaces.CorrespondenceProviding;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.interfaces.MappingManaging;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.interfaces.MetamodelManaging;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.interfaces.ModelProviding;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.internal.InternalContractsBuilder;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.internal.InternalCorrespondenceModel;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.util.bridges.EMFCommandBridge;
import edu.kit.ipd.sdq.vitruvius.framework.util.bridges.EcoreResourceBridge;
import edu.kit.ipd.sdq.vitruvius.framework.util.datatypes.Pair;
import edu.kit.ipd.sdq.vitruvius.framework.vsum.helper.FileSystemHelper;

public class VSUMImpl implements ModelProviding, CorrespondenceProviding {

    private static final Logger logger = Logger.getLogger(VSUMImpl.class.getSimpleName());

    private final MappingManaging mappingManaging;
    private final MetamodelManaging metamodelManaging;
    // private final ViewTypeManaging viewTypeManaging;

    protected final Map<VURI, ModelInstance> modelInstances;
    private final ResourceSet resourceSet;
    private final Map<Mapping, InternalCorrespondenceModel> mapping2CorrespondenceModelMap;

    // private ClassLoader classLoader;

    public VSUMImpl(final MetamodelManaging metamodelManaging, final MappingManaging mappingManaging) {
        this(metamodelManaging, mappingManaging, null);
    }

    public VSUMImpl(final MetamodelManaging metamodelManaging, final MappingManaging mappingManaging,
            final ClassLoader classLoader) {
        this.metamodelManaging = metamodelManaging;
        // this.viewTypeManaging = viewTypeManaging;
        this.mappingManaging = mappingManaging;

        this.resourceSet = new ResourceSetImpl();

        this.modelInstances = new HashMap<VURI, ModelInstance>();
        this.mapping2CorrespondenceModelMap = new HashMap<Mapping, InternalCorrespondenceModel>();

        // this.classLoader = classLoader;

        loadVURIsOfVSMUModelInstances();
        loadAndMapCorrepondenceInstances();
    }

    @Override
    public ModelInstance getModelInstanceCopy(final VURI uri) {
        // TODO Auto-generated method stub

        return null;
    }

    /**
     * Supports three cases: 1) get registered 2) create non-existing 3) get unregistered but
     * existing that contains at most a root element without children. But throws an exception if an
     * instance that contains more than one element exists at the uri.
     *
     * DECISION Since we do not throw an exception (which can happen in 3) we always return a valid
     * model. Hence the caller do not have to check whether the retrieved model is null.
     */
    private ModelInstance getAndLoadModelInstanceOriginal(final VURI modelURI,
            final boolean forceLoadByDoingUnloadBeforeLoad) {
        final ModelInstance modelInstance = getModelInstanceOriginal(modelURI);
        EMFCommandBridge.createAndExecuteVitruviusRecordingCommand(new Callable<Void>() {
            @Override
            public Void call() {
                try {
                    modelInstance.load(getMetamodelByURI(modelURI).getDefaultLoadOptions(),
                            forceLoadByDoingUnloadBeforeLoad);
                } catch (RuntimeException re) {
                    // could not load model instance --> this should only be the case when the
                    // model is not existing yet
                    logger.info("Exception during loading of model instance " + modelInstance + " occured: " + re);
                }
                return null;
            }
        }, this);

        return modelInstance;
    }

    @Override
    public ModelInstance getAndLoadModelInstanceOriginal(final VURI modelURI) {
        return getAndLoadModelInstanceOriginal(modelURI, false);
    }

    @Override
    public void forceReloadModelInstanceOriginalIfExisting(final VURI modelURI) {
        if (existsModelInstance(modelURI)) {
            getAndLoadModelInstanceOriginal(modelURI, true);
        }
    }

    public ModelInstance getModelInstanceOriginal(final VURI modelURI) {
        ModelInstance modelInstance = this.modelInstances.get(modelURI);
        if (modelInstance == null) {
            EMFCommandBridge.createAndExecuteVitruviusRecordingCommand(new Callable<Void>() {
                @Override
                public Void call() {
                    // case 2 or 3
                    ModelInstance internalModelInstance = getOrCreateUnregisteredModelInstance(modelURI);
                    VSUMImpl.this.modelInstances.put(modelURI, internalModelInstance);
                    saveVURIsOfVSUMModelInstances();
                    return null;
                }
            }, this);
            modelInstance = this.modelInstances.get(modelURI);
        }
        return modelInstance;
    }

    public boolean existsModelInstance(final VURI modelURI) {
        return this.modelInstances.containsKey(modelURI);
    }

    /**
     * Saves the resource for the given vuri. If the VURI is not existing yet it will be created.
     *
     * @param vuri
     *            The VURI to save
     */
    @Override
    public void saveExistingModelInstanceOriginal(final VURI vuri) {
        saveExistingModelInstanceOriginal(vuri, null);
    }

    private void saveExistingModelInstanceOriginal(final VURI vuri,
            final Pair<EObject, TUID> tuidToUpdateWithRootEObjectPair) {
        EMFCommandBridge.createAndExecuteVitruviusRecordingCommand(new Callable<Void>() {
            @Override
            public Void call() throws Exception {
                ModelInstance modelInstanceToSave = getModelInstanceOriginal(vuri);
                Metamodel metamodel = getMetamodelByURI(vuri);
                Resource resourceToSave = modelInstanceToSave.getResource();
                try {
                    EcoreResourceBridge.saveResource(resourceToSave, metamodel.getDefaultSaveOptions());
                } catch (IOException e) {
                    throw new RuntimeException("Could not save VURI + " + vuri + ": " + e);
                }
                saveAllChangedCorrespondences(modelInstanceToSave, tuidToUpdateWithRootEObjectPair);
                for (EObject root : modelInstanceToSave.getRootElements()) {
                    metamodel.removeRootFromTUIDCache(root);
                }
                return null;
            }

        }, this);
    }

    @Override
    public void saveModelInstanceOriginalWithEObjectAsOnlyContent(final VURI vuri, final EObject rootEObject,
            final TUID oldTUID) {
        final ModelInstance modelInstance = getAndLoadModelInstanceOriginal(vuri);

        EMFCommandBridge.createAndExecuteVitruviusRecordingCommand(new Callable<Void>() {
            @Override
            public Void call() throws Exception {
                final Resource resource = modelInstance.getResource();
                // clear the resource first
                resource.getContents().clear();
                resource.getContents().add(rootEObject);
                VSUMImpl.this.saveExistingModelInstanceOriginal(vuri, new Pair<EObject, TUID>(rootEObject, oldTUID));
                return null;
            }
        }, this);
    }

    private void saveAllChangedCorrespondences(final ModelInstance modelInstanceToSave,
            final Pair<EObject, TUID> tuidToUpdateNewRootEObjectPair) {
        VURI metamodeURI = modelInstanceToSave.getMetamodeURI();
        Metamodel metamodel = this.metamodelManaging.getMetamodel(metamodeURI);
        Set<InternalCorrespondenceModel> allCorrespondenceModels = getOrCreateAllInternalCorrespondenceModelsForMM(
                metamodel);
        for (InternalCorrespondenceModel correspondenceModel : allCorrespondenceModels) {
            if (null != tuidToUpdateNewRootEObjectPair && tuidToUpdateNewRootEObjectPair.getSecond() != null) {
                correspondenceModel.updateTUID(tuidToUpdateNewRootEObjectPair.getSecond(),
                        tuidToUpdateNewRootEObjectPair.getFirst());
            }
            if (correspondenceModel.changedAfterLastSave()) {
                saveCorrespondenceModelAndDecorators(correspondenceModel);
                correspondenceModel.resetChangedAfterLastSave();
            }
        }
    }

    @Override
    public void saveCorrespondenceModelAndDecorators(final CorrespondenceModel correspondenceModel) {
        // FIXME HK This is really bad
        ((InternalCorrespondenceModel) correspondenceModel).saveModel();
    }

    private ModelInstance getOrCreateUnregisteredModelInstance(final VURI modelURI) {
        String fileExtension = modelURI.getFileExtension();
        Metamodel metamodel = this.metamodelManaging.getMetamodel(fileExtension);
        if (metamodel == null) {
            throw new RuntimeException("Cannot create a new model instance at the uri '" + modelURI
                    + "' because no metamodel is registered for the file extension '" + fileExtension + "'!");
        }
        return getOrCreateUnregisteredModelInstance(modelURI, metamodel);
    }

    private ModelInstance getOrCreateUnregisteredModelInstance(final VURI modelURI, final Metamodel metamodel) {
        ModelInstance modelInstance = loadModelInstance(modelURI, metamodel);
        getOrCreateAllCorrespondenceModelsForMM(metamodel);
        return modelInstance;
    }

    private ModelInstance loadModelInstance(final VURI modelURI, final Metamodel metamodel) {
        URI emfURI = modelURI.getEMFUri();
        Resource modelResource = EcoreResourceBridge.loadResourceAtURI(emfURI, this.resourceSet,
                metamodel.getDefaultLoadOptions());
        ModelInstance modelInstance = new ModelInstance(modelURI, modelResource);
        return modelInstance;
    }

    private Collection<Mapping> getAllMappings(final Metamodel metamodel) {
        return this.mappingManaging.getAllMappings(metamodel);
    }

    public Set<CorrespondenceModel> getOrCreateAllCorrespondenceModelsForMM(final Metamodel metamodel) {
        return new HashSet<CorrespondenceModel>(getOrCreateAllInternalCorrespondenceModelsForMM(metamodel));
    }

    private Set<InternalCorrespondenceModel> getOrCreateAllInternalCorrespondenceModelsForMM(
            final Metamodel metamodel) {
        Collection<Mapping> mappings = getAllMappings(metamodel);
        Set<InternalCorrespondenceModel> correspondenceModels = new HashSet<InternalCorrespondenceModel>(
                null == mappings ? 0 : mappings.size());
        if (null == mappings) {
            logger.warn("mappings == null. No correspondence instace for MM: " + metamodel + " created."
                    + "Empty correspondence list will be returned");
            return correspondenceModels;
        }
        for (Mapping mapping : mappings) {
            InternalCorrespondenceModel correspondenceModel = this.mapping2CorrespondenceModelMap.get(mapping);
            if (correspondenceModel == null) {
                correspondenceModel = createAndRegisterCorrespondenceModel(mapping);
            }
            correspondenceModels.add(correspondenceModel);
        }
        return correspondenceModels;
    }

    private InternalCorrespondenceModel createAndRegisterCorrespondenceModel(final Mapping mapping) {
        InternalCorrespondenceModel correspondenceModel;
        VURI[] mmURIs = mapping.getMetamodelURIs();
        VURI correspondencesVURI = FileSystemHelper.getCorrespondencesVURI(mmURIs);
        correspondenceModel = createCorrespondenceModel(mapping, correspondencesVURI);
        // if (correspondenceModel instanceof InternalCorrespondenceModel) {
        // loadAndInitializeCorrespondenceModelDecorators(correspondenceModel);
        // }
        this.mapping2CorrespondenceModelMap.put(mapping, correspondenceModel);
        return correspondenceModel;
    }

    private InternalCorrespondenceModel createCorrespondenceModel(final Mapping mapping,
            final VURI correspondencesVURI) {
        Resource correspondencesResource = this.resourceSet.createResource(correspondencesVURI.getEMFUri());
        return InternalContractsBuilder.createCorrespondenceModel(mapping, this, correspondencesVURI,
                correspondencesResource);
    }

    // private void loadAndInitializeCorrespondenceModelDecorators(
    // final InternalCorrespondenceModel correspondenceModel) {
    // Set<String> fileExtPrefixesForObjects =
    // correspondenceModel.getFileExtPrefixesForObjectsToLoad();
    // Map<String, Object> fileExtPrefix2ObjectMap = new HashMap<String, Object>();
    // for (String fileExtPrefix : fileExtPrefixesForObjects) {
    // String fileName = getFileNameForCorrespondenceModelDecorator(correspondenceModel,
    // fileExtPrefix);
    // Object loadedObject = FileSystemHelper.loadObjectFromFile(fileName, this.classLoader);
    // fileExtPrefix2ObjectMap.put(fileExtPrefix, loadedObject);
    // }
    // correspondenceModel.initialize(fileExtPrefix2ObjectMap);
    // }

    // @Override
    public ModelInstance getModelInstanceOriginalForImport(final VURI uri) {
        // TODO Auto-generated method stub
        return null;
    }

    /**
     * Returns the correspondenceModel for the mapping from the metamodel at the first VURI to the
     * metamodel at the second VURI or the other way round
     *
     * @return the found correspondenceModel or null if there is none
     */
    @Override
    public CorrespondenceModel getCorrespondenceModelOriginal(final VURI mmAVURI, final VURI mmBVURI) {
        Mapping mapping = this.mappingManaging.getMapping(mmAVURI, mmBVURI);
        if (this.mapping2CorrespondenceModelMap.containsKey(mapping)) {
            return this.mapping2CorrespondenceModelMap.get(mapping);
        }
        logger.warn("no mapping found for the metamodel at: " + mmAVURI + " and the metamodel at: " + mmBVURI);
        return null;
    }

    /**
     * Returns all correspondences instances for a given VURI. null will be returned. We are not
     * creating new CorrespondenceModel here, cause we can not guess the linked model. The method
     * {@link getCorrespondenceModelOriginal} must be called before to create the appropriate
     * correspondence instance
     *
     * @see edu.kit.ipd.sdq.vitruvius.framework.contracts.meta.correspondence.datatypes.
     *      CorrespondenceModel
     * @return set that contains all CorrespondenceModels for the VURI or null if there is non
     */
    @Override
    public Set<CorrespondenceModel> getOrCreateAllCorrespondenceModels(final VURI model1uri) {
        Metamodel metamodelForUri = this.metamodelManaging.getMetamodel(model1uri.getFileExtension());
        return getOrCreateAllCorrespondenceModelsForMM(metamodelForUri);
    }

    @Override
    public CorrespondenceModel getCorrespondenceModelCopy(final VURI model1uri, final VURI model2uri) {
        // TODO Auto-generated method stub
        return null;
    }

    private void loadVURIsOfVSMUModelInstances() {
        Set<VURI> vuris = FileSystemHelper.loadVSUMvURIsFromFile();
        for (VURI vuri : vuris) {
            Metamodel metamodel = getMetamodelByURI(vuri);
            ModelInstance modelInstance = loadModelInstance(vuri, metamodel);
            this.modelInstances.put(vuri, modelInstance);
        }
    }

    private void saveVURIsOfVSUMModelInstances() {
        FileSystemHelper.saveVSUMvURIsToFile(this.modelInstances.keySet());
    }

    private Metamodel getMetamodelByURI(final VURI uri) {
        String fileExtension = uri.getFileExtension();
        return this.metamodelManaging.getMetamodel(fileExtension);
    }

    private void loadAndMapCorrepondenceInstances() {
        Metamodel[] metamodels = this.metamodelManaging.getAllMetamodels();
        for (Metamodel metamodel : metamodels) {
            getOrCreateAllCorrespondenceModelsForMM(metamodel);
        }
    }

    @Override
    public synchronized TransactionalEditingDomain getTransactionalEditingDomain() {
        if (null == TransactionalEditingDomain.Factory.INSTANCE.getEditingDomain(this.resourceSet)) {
            attachTransactionalEditingDomain();
        }
        return TransactionalEditingDomain.Factory.INSTANCE.getEditingDomain(this.resourceSet);
    }

    private void attachTransactionalEditingDomain() {
        TransactionalEditingDomain.Factory.INSTANCE.createEditingDomain(this.resourceSet);
    }

    @Override
    public void detachTransactionalEditingDomain() {
        TransactionalEditingDomain domain = TransactionalEditingDomain.Factory.INSTANCE
                .getEditingDomain(this.resourceSet);
        if (domain != null) {
            domain.dispose();
        }
    }

    @Override
    public void deleteModelInstanceOriginal(final VURI vuri) {
        final ModelInstance modelInstance = getModelInstanceOriginal(vuri);
        final Resource resource = modelInstance.getResource();
        EMFCommandBridge.createAndExecuteVitruviusRecordingCommand(new Callable<Void>() {
            @Override
            public Void call() throws Exception {
                try {
                    resource.delete(null);
                    VSUMImpl.this.modelInstances.remove(modelInstance);
                } catch (final IOException e) {
                    logger.info("Deletion of resource " + resource + " did not work. Reason: " + e);
                }
                return null;
            }
        }, this);
    }
}
