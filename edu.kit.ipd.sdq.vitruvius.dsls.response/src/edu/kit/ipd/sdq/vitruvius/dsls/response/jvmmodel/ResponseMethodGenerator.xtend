package edu.kit.ipd.sdq.vitruvius.dsls.response.jvmmodel

import edu.kit.ipd.sdq.vitruvius.dsls.response.jvmmodel.JvmTypesBuilderWithoutAssociations
import org.eclipse.xtext.xbase.jvmmodel.JvmTypeReferenceBuilder
import org.eclipse.xtext.common.types.JvmVisibility
import edu.kit.ipd.sdq.vitruvius.dsls.response.responseLanguage.Response
import edu.kit.ipd.sdq.vitruvius.framework.meta.change.EChange
import org.eclipse.xtext.common.types.JvmOperation
import static edu.kit.ipd.sdq.vitruvius.dsls.response.api.generator.ResponseLanguageGeneratorConstants.*;
import org.eclipse.emf.ecore.EObject
import java.util.ArrayList
import org.eclipse.xtext.common.types.JvmFormalParameter
import edu.kit.ipd.sdq.vitruvius.framework.contracts.datatypes.Blackboard
import edu.kit.ipd.sdq.vitruvius.dsls.response.responseLanguage.ConcreteModelElementChange
import static extension edu.kit.ipd.sdq.vitruvius.dsls.response.helper.EChangeHelper.*;
import edu.kit.ipd.sdq.vitruvius.dsls.response.responseLanguage.PreconditionBlock
import java.util.List
import edu.kit.ipd.sdq.vitruvius.dsls.response.api.runtime.ResponseRuntimeHelper
import java.util.Map
import java.util.HashMap
import org.eclipse.emf.common.util.URI
import java.util.Collections
import edu.kit.ipd.sdq.vitruvius.dsls.response.generator.impl.SimpleTextXBlockExpression
import java.io.IOException
import org.eclipse.xtend2.lib.StringConcatenationClient
import edu.kit.ipd.sdq.vitruvius.dsls.response.responseLanguage.ExecutionBlock
import static extension edu.kit.ipd.sdq.vitruvius.dsls.response.helper.EChangeHelper.*;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.datatypes.TransformationResult
import edu.kit.ipd.sdq.vitruvius.dsls.response.responseLanguage.AtomicFeatureChange
import static extension edu.kit.ipd.sdq.vitruvius.dsls.response.helper.ResponseLanguageHelper.*;
import edu.kit.ipd.sdq.vitruvius.dsls.response.responseLanguage.PathToSourceSpecificationBlock
import edu.kit.ipd.sdq.vitruvius.dsls.response.responseLanguage.ConcreteTargetModelChange
import edu.kit.ipd.sdq.vitruvius.dsls.response.responseLanguage.ConcreteTargetModelUpdate
import edu.kit.ipd.sdq.vitruvius.dsls.response.responseLanguage.ConcreteTargetModelCreate
import edu.kit.ipd.sdq.vitruvius.dsls.response.responseLanguage.CorrespondingModelElementSpecification
import edu.kit.ipd.sdq.vitruvius.framework.util.bridges.CollectionBridge
import org.eclipse.emf.ecore.change.ChangeDescription
import edu.kit.ipd.sdq.vitruvius.framework.contracts.datatypes.VURI
import edu.kit.ipd.sdq.vitruvius.dsls.response.responseLanguage.CorrespondingModelElementCreate
import edu.kit.ipd.sdq.vitruvius.framework.meta.change.object.DeleteRootEObject
import org.eclipse.emf.ecore.util.EcoreUtil
import edu.kit.ipd.sdq.vitruvius.dsls.response.responseLanguage.CorrespondingModelElementDelete
import edu.kit.ipd.sdq.vitruvius.dsls.response.responseLanguage.CorrespondingModelElementRetrieveOrDelete

class ResponseMethodGenerator {
	@Extension protected static JvmTypeReferenceBuilder _typeReferenceBuilder;
	protected extension JvmTypesBuilderWithoutAssociations _typesBuilder;
	
	protected final Response response;
	protected final boolean hasTargetChange;
	protected final boolean hasConcreteTargetChange;
	protected final boolean hasPreconditionBlock;
	protected final boolean hasExecutionBlock;
	protected final boolean isBlackboardAvailable;
	protected final Class<? extends EChange> change;
	
	protected Map<String, JvmOperation> methodMap;
	
	private extension IJvmOperationRegistry _operationRegistry;
	private extension ResponseParameterGenerator _parameterGenerator;
	private extension final ResponseElementsCompletionChecker _completionChecker; 
	
	new(Response response, IJvmOperationRegistry registry, JvmTypeReferenceBuilder typeReferenceBuilder, JvmTypesBuilderWithoutAssociations jvmTypesBuilder) {
		this.response = response;
		this.hasTargetChange = response.effects.targetChange != null;
		this.hasConcreteTargetChange = this.hasTargetChange && response.effects.targetChange instanceof ConcreteTargetModelChange;
		this.hasPreconditionBlock = response.trigger.precondition != null;
		this.hasExecutionBlock = response.effects.codeBlock != null;
		this.isBlackboardAvailable = !hasConcreteTargetChange;
		this.change = response.trigger.generateEChangeInstanceClass();
		this.methodMap = new HashMap<String, JvmOperation>();
		_operationRegistry = registry;
		_parameterGenerator = new ResponseParameterGenerator(response, typeReferenceBuilder, jvmTypesBuilder);
		_completionChecker = new ResponseElementsCompletionChecker();
		_typesBuilder = jvmTypesBuilder;
		_typeReferenceBuilder = typeReferenceBuilder;
	}
	
	/**
	 * Generates method: applyChange
	 * 
	 * <p>Applies the given change to the specified response. Executes the response if all preconditions are fulfilled.
	 * 
	 * <p>Method parameters are:
	 * <li>1. change: the change event ({@link EChange})
	 * <li>2. blackboard: the {@link Blackboard} containing the {@link CorrespondenceInstance} 
	 * 
	 */
	protected def generateMethodApplyChange() {
		val methodName = RESPONSE_APPLY_METHOD_NAME;
		
		return getOrGenerateMethod(methodName, typeRef(TransformationResult)) [
			visibility = JvmVisibility.PUBLIC;
			val changeParameter = generateUntypedChangeParameter();
			val blackboardParameter = generateBlackboardParameter();
			parameters += changeParameter;
			parameters += blackboardParameter;
			val typedChangeName = "typedChange";
			val checkPreconditionMethod = generateInterfacePreconditionMethod();
			val executeResponseMethod = generateMethodExecuteResponse();
			body = '''
				LOGGER.debug("Called response " + this.getClass().getName() + " with event " + «changeParameter.name»);
				
				// Check if the event matches the trigger of the response
				if (!«checkPreconditionMethod.simpleName»(«changeParameter.name»)) {
					return new «TransformationResult»();
				}
				
				«typedChangeString» «typedChangeName» = («typedChangeString»)«changeParameter.name»;
				try {
					«executeResponseMethod.simpleName»(«typedChangeName», «blackboardParameter.name»);
				} catch («Exception» exception) {
					// If an error occured during execution, avoid an application shutdown and print the error.
					LOGGER.error(exception.getClass().getSimpleName() + " (" + exception.getMessage() + ") during execution of response: " + this.getClass().getName());
				}
				
				return new «TransformationResult»();'''
		];
	}
	
	private def StringConcatenationClient getTypedChangeString() '''
		«val trigger = response.trigger
		»«change»«IF trigger instanceof ConcreteModelElementChange»<«getGenericTypeParameterOfChange(trigger)»>«ENDIF»'''
		
	
		
	protected def generateMethodGetTrigger() {
		val methodName = "getTrigger";
		return getOrGenerateMethod(methodName, typeRef(Class, wildcardExtends(typeRef(EChange)))) [
			static = true;
			body = '''return «change».class;'''
		];
	} 
	
	/** 
	 * Generated method: checkPrecondition : boolean
	 * 
	 * <p>Evaluates the precondition specified in the response
	 * 
	 * <p>Methods parameters are: 
	 * 	<li>1. change: the change event ({@link EChange})</li>
	 * 
	 * <p>Precondition: precondition code block must exist.
	 */
	protected def generateInterfacePreconditionMethod() {
		val methodName = PRECONDITION_METHOD_NAME;
		val operationsToCallBeforeCast = getPreconditionMethodsBeforeCast();
		val operationsToCallAfterCast = getPreconditionMethodsAfterCast();
		return getOrGenerateMethod(methodName, typeRef(Boolean.TYPE)) [
			val changeParameter = generateUntypedChangeParameter(response);
			val typedChangeClass = change;
			visibility = JvmVisibility.PUBLIC;
			parameters += changeParameter
			body = '''
				«FOR operation : operationsToCallBeforeCast»
					if (!«operation.simpleName»(«changeParameter.name»)) {
						return false;
					}
				«ENDFOR»
				«typedChangeClass» typedChange = («typedChangeClass»)«changeParameter.name»;
				«FOR operation : operationsToCallAfterCast»
					if (!«operation.simpleName»(typedChange)) {
						return false;
					}
				«ENDFOR»
				LOGGER.debug("Passed precondition check of response " + this.getClass().getName());
				return true;
				'''
		];
	}
	
	protected def generateMethodCheckChangeType() {
		val methodName = "checkChangeType";
		return getOrGenerateMethod(methodName, typeRef(Boolean.TYPE)) [
			val changeParameter = generateUntypedChangeParameter;
			visibility = JvmVisibility.PRIVATE;
			parameters += changeParameter;
			val changeType = if (!change.equals(EChange)) {
				typeRef(change, wildcard);
			} else {
				typeRef(change);
			}
			body = '''return «changeParameter.name» instanceof «changeType»;''';
		];	
	}
	
	/** 
	 * Generated method: checkPrecondition : boolean
	 * 
	 * <p>Evaluates the precondition specified in the response
	 * 
	 * <p>Methods parameters are: 
	 * 	<li>1. change: the change event ({@link EChange})</li>
	 * 
	 * <p>Precondition: precondition code block must exist.
	 */
	protected def JvmOperation generateUserDefinedPreconditionMethod(PreconditionBlock preconditionBlock) {
		val methodName = TRIGGER_PRECONDITION_METHOD_NAME;
		
		return preconditionBlock.getOrGenerateMethod(methodName, typeRef(Boolean.TYPE)) [
			visibility = JvmVisibility.PRIVATE;
			parameters += generateChangeParameter(preconditionBlock);
			body = preconditionBlock.code;
		];		
	}
	
	
	protected def JvmOperation generateMethodGetPathFromSource(PathToSourceSpecificationBlock pathFromSourceBlock) {
		val methodName = "getPathFromSource";
		
		return pathFromSourceBlock.getOrGenerateMethod(methodName, typeRef(String)) [
			visibility = JvmVisibility.PRIVATE;
			parameters += generateChangeParameter(pathFromSourceBlock);
			body = pathFromSourceBlock.code;
		];		
	}
	
	/**
	 * Generates method: determineTargetModels
	 * 
	 * <p>Checks the CorrespondenceInstance in the specified blackboard for corresponding objects
	 * according to the type and constraints specified in the response.
	 * 
	 * <p>Method parameters are:
	 * 	<li>1. change: the change event ({@link EChange})</li>
	 *  <li>2. blackboard: the blackboard ({@link Blackboard})</li>
	 * 
	 * <p>Precondition: a metamodel element for the target models is specified in the response
	 */	
	protected def generateMethodGetCorrespondingModelElements(CorrespondingModelElementSpecification correspondingModelElement, CorrespondingModelElementSpecification correspondingModel, boolean claimSizeOne) {
		val methodName = "getCorrespondingModelElements" + correspondingModelElement.name.toFirstUpper;
		val correspondenceSourceMethod = generateMethodGetCorrespondenceSource(correspondingModelElement)
		
		val affectedElementClass = correspondingModelElement?.elementType.javaClass;
		if (affectedElementClass == null) {
			return null;
		}
		
		var returnType = typeRef(affectedElementClass);
		if (!claimSizeOne) {
			returnType = typeRef(Iterable, returnType);
		}
		return getOrGenerateMethod(methodName, returnType) [
			visibility = JvmVisibility.PRIVATE;
			val changeParameter = generateChangeParameter();	
			val blackboardParameter = generateBlackboardParameter();
			val targetModelParameter = if (correspondingModel != null) {
				generateModelElementParameter(correspondingModel);
			};
			parameters += changeParameter;
			parameters += blackboardParameter;
			parameters += targetModelParameter;
			body = '''
				«List»<«affectedElementClass»> _targetModels = new «ArrayList»<«affectedElementClass»>();
				«EObject» _sourceElement = «correspondenceSourceMethod.simpleName»(«changeParameter.name»);
				«EObject» _sourceParent = null;
				«/* TODO HK Fix this after the new change MM is implemented:
				 * Delete objects (except root one) are removed from the model and now contained in the ChangeDescription,
				 * so correspondences cannot be resolved
				 */»
				«IF !(response.trigger instanceof ConcreteModelElementChange && DeleteRootEObject.equals(change))»
				if (_sourceElement.eContainer() instanceof «ChangeDescription») {
					_sourceParent = «changeParameter.name».getOldAffectedEObject();
				}
				«ENDIF»
				«Iterable»<«affectedElementClass»> _correspondingObjects = «ResponseRuntimeHelper».getCorrespondingObjectsOfType(
						«blackboardParameter.name».getCorrespondenceInstance(), _sourceElement, _sourceParent, «affectedElementClass».class);
				
				for («affectedElementClass» _potentialTargetElement : _correspondingObjects) {
					«IF targetModelParameter != null»
					if («targetModelParameter.name» == null || _potentialTargetElement.eResource().equals(«targetModelParameter.name».eResource())) {
						_targetModels.add(_potentialTargetElement);
					}
					«ELSE»
					_targetModels.add(_potentialTargetElement);
					«ENDIF»
				}
				
				«IF correspondingModelElement instanceof CorrespondingModelElementDelete»
				for («EObject» _targetModel : _targetModels) {
					«ResponseRuntimeHelper».removeCorrespondence(«blackboardParameter.name».getCorrespondenceInstance(), _sourceElement, _sourceParent, _targetModel, null);
				}
				«ENDIF»
									
				«IF claimSizeOne»
					if (_targetModels.size() != 1) {
						throw new «IllegalArgumentException»("There has to be exacty one corresponding element.");
					}
					return _targetModels.get(0);
				«ELSE»
					return _targetModels;
				«ENDIF»
			'''
		];
	}
	
	protected def generateMethodGetCorrespondenceSource(CorrespondingModelElementSpecification modelElementSpecification) {
		val methodName = "getCorrepondenceSource" + modelElementSpecification.name.toFirstUpper;
		
		return modelElementSpecification.correspondenceSource.getOrGenerateMethod(methodName, typeRef(EObject)) [
			visibility = JvmVisibility.PRIVATE;
			parameters += generateChangeParameter(modelElementSpecification);
			val correspondenceSourceBlock = modelElementSpecification.correspondenceSource?.code;
			if (correspondenceSourceBlock instanceof SimpleTextXBlockExpression) {
				body = correspondenceSourceBlock.text;
			} else {
				body = correspondenceSourceBlock;
			}
		];
	}
	
	/**
	 * Generates method: generateTargetModel
	 * 
	 * <p>Generates a new target model as specified in the response
	 * 
	 * <p>Method parameters are:
	 * 	<li>1. change: the change event ({@link EChange})</li>
	 *  <li>2. blackboard: the blackboard ({@link Blackboard})</li>
	 * 
	 * <p>Precondition: a metamodel element to be the root of the new model is specified in the response
	 */	
	protected def generateMethodGenerateTargetModel(ConcreteTargetModelCreate createdModel) {
		val methodName = "generateTargetModel";
		
		return getOrGenerateMethod(methodName, typeRef(Void.TYPE)) [ 
			visibility = JvmVisibility.PRIVATE;
			val changeParameter = generateChangeParameter();
			val blackboardParameter = generateBlackboardParameter();
			val rootParameter = generateModelElementParameter(createdModel.rootElement);
			parameters += changeParameter;
			parameters += blackboardParameter;
			parameters += rootParameter;
			exceptions += typeRef(IOException);
			val correspondenceSourceMethod = generateMethodGetCorrespondenceSource(createdModel.rootElement);
			val pathFromSourceMethod = generateMethodGetPathFromSource(createdModel.relativeToSourcePath);
			body = '''
				«EObject» sourceElement = «correspondenceSourceMethod.simpleName»(«changeParameter.name»);
				«String» relativePath = «pathFromSourceMethod.simpleName»(«changeParameter.name»);
				«URI» resourceURI = «ResponseRuntimeHelper».«
				IF (createdModel.useRelativeToSource)»getURIFromSourceResourceFolder«
				ELSEIF (createdModel.useRelativeToProject)»getURIFromSourceProjectFolder«
				ENDIF»(sourceElement, relativePath, «blackboardParameter.name»); 
				«blackboardParameter.name».getModelProviding().saveModelInstanceOriginalWithEObjectAsOnlyContent(«VURI».getInstance(resourceURI), «rootParameter.name», null);
				«blackboardParameter.name».getCorrespondenceInstance().createAndAddCorrespondence(«Collections».singletonList(sourceElement), «Collections».singletonList(«rootParameter.name»));
			'''
		];
	}
	
	
	/**
	 * Generates method: generateTargetModel
	 * 
	 * <p>Generates a new target model as specified in the response
	 * 
	 * <p>Method parameters are:
	 * 	<li>1. change: the change event ({@link EChange})</li>
	 *  <li>2. blackboard: the blackboard ({@link Blackboard})</li>
	 * 
	 * <p>Precondition: a metamodel element to be the root of the new model is specified in the response
	 */	
	protected def StringConcatenationClient generateCodeGenerateModelElement(CorrespondingModelElementSpecification elementSpecification, String assignedVariableName) {
		if (!elementSpecification.complete) {
			return '''''';
		}
		val affectedElementClass = elementSpecification.elementType.element;
		val createdClassFactory = affectedElementClass.EPackage.EFactoryInstance.class;
		return '''«affectedElementClass.instanceClass» «assignedVariableName» = «createdClassFactory».eINSTANCE.create«affectedElementClass.name»();'''
	}
	
	protected def StringConcatenationClient generateCodeAddModelElementCorrespondence(CorrespondingModelElementSpecification elementSpecification, JvmFormalParameter changeParameter, JvmFormalParameter blackboardParameter, String newElementVariableName) {
		val correspondenceSourceMethod = generateMethodGetCorrespondenceSource(elementSpecification);
		return ''' 
			«ResponseRuntimeHelper».addCorrespondence(«blackboardParameter.name».getCorrespondenceInstance(), 
				«correspondenceSourceMethod.simpleName»(«changeParameter.name»), «newElementVariableName»);'''
	}
	
	/**
	 * Generates method: deleteTargetModel
	 * 
	 * <p>Delete the target model as specified in the response
	 * 
	 * <p>Method parameters are:
	 * 	<li>1. change: the change event ({@link EChange})</li>
	 *  <li>2. blackboard: the blackboard ({@link Blackboard})</li>
	 */	
	protected def StringConcatenationClient generateCodeDeleteElement(String deleteElementVariableName) {
		if (DeleteRootEObject.equals(change)) {
			return '''
				LOGGER.debug("Deleting root object: " + «deleteElementVariableName»);
				«deleteElementVariableName».eResource().delete(«Collections».EMPTY_MAP);'''
		} else {
			return '''
				LOGGER.debug("Removing non-root object: " + «deleteElementVariableName»);
				«EcoreUtil».remove(«deleteElementVariableName»);'''	
		}
	} 
	
	protected def Iterable<JvmOperation> getPreconditionMethodsBeforeCast() {
		val methods = <JvmOperation>newArrayList();
		methods += generateMethodCheckChangeType();
		if (response.trigger instanceof ConcreteModelElementChange) {
			methods += generateMethodCheckChangedObject();
		}
		return methods;
	}
	
	protected def Iterable<JvmOperation> getPreconditionMethodsAfterCast() {
		val methods = <JvmOperation>newArrayList();
		if (hasPreconditionBlock) {
			methods += generateUserDefinedPreconditionMethod(response.trigger.precondition);
		}
		return methods;
	}
	
	/**
	 * Generates method: checkChangedObject : boolean
	 * 
	 * <p>Checks if the currently changed object equals the one specified in the response.
	 * 
	 * <p>Methods parameters are:
	 * 	<li>1. change: the change event ({@link EChange})</li>
	 */
	protected def generateMethodCheckChangedObject() {
		val methodName = "checkChangedObject";
		
		if (!(response.trigger instanceof ConcreteModelElementChange)) {
			throw new IllegalStateException();
		}
		
		val changeEvent = response.trigger;
		val changedElement = response.trigger.changedModelElementClass;
		return getOrGenerateMethod(methodName, typeRef(Boolean.TYPE)) [
			visibility = JvmVisibility.PRIVATE;
			val changeParameter = generateUntypedChangeParameter();
			parameters += changeParameter;
			val typedChangeName = "typedChange";
			val typedChangeClassGenericString = if (!change.equals(EChange)) "<?>" else ""
			body = '''
				«change»«typedChangeClassGenericString» «typedChangeName» = («change»«typedChangeClassGenericString»)«changeParameter.name»;
				«EObject» changedElement = «typedChangeName».get«changeEvent.EChangeFeatureNameOfChangedObject.toFirstUpper»();
				«IF changeEvent instanceof AtomicFeatureChange»
					«/* TODO HK We could compare something more safe like <MM>PackageImpl.eINSTANCE.<ELEMENT>_<FEATURE>.*/»
					if (!«typedChangeName».getAffectedFeature().getName().equals("«changeEvent.changedFeature.feature.name»")) {
						return false;
					}
				«ENDIF»
				if (changedElement instanceof «changedElement.instanceClass») {
					return true;
				}
				return false;
			'''
		];
	}
	
	protected def generateMethodPerformResponse(ExecutionBlock executionBlock, CorrespondingModelElementSpecification... modelElements) {
		val methodName = "performResponseTo";
		return executionBlock.getOrGenerateMethod(methodName, typeRef(Void.TYPE)) [
			visibility = JvmVisibility.PRIVATE;
			parameters += generateChangeParameter;
			val generatedMethod = it;
			parameters += modelElements.map[generateModelElementParameter(generatedMethod, it)];
			if (isBlackboardAvailable) {
				parameters += generateBlackboardParameter;
			}
			val code = executionBlock.code;
			if (code instanceof SimpleTextXBlockExpression) {
				body = code.text;
			} else {
				body = code;
			}
		];	
	}
	
	protected def generateMethodExecuteResponse() {
		val methodName = "executeResponse";
		return getOrGenerateMethod(methodName, typeRef(Void.TYPE)) [
			visibility = JvmVisibility.PRIVATE;
			exceptions += typeRef(IOException);
			val changeParameter = generateChangeParameter();
			val blackboardParameter = generateBlackboardParameter();
			parameters += changeParameter;
			parameters += blackboardParameter;
			if (hasConcreteTargetChange) {
				val modelRootChange = response.effects.targetChange as ConcreteTargetModelChange;
				body = generateMethodExecuteResponseBody(modelRootChange, changeParameter, blackboardParameter);
			} else {
				body = generateMethodExecuteResponseBody(changeParameter, blackboardParameter);
			}
		];	
	}
	
	
	private def JvmOperation generateMethodExecuteForTargetModel(
			CorrespondingModelElementSpecification targetModelElement,
			Iterable<CorrespondingModelElementCreate> createElements, 
			Iterable<CorrespondingModelElementRetrieveOrDelete> retrieveElements) {
		val methodName = "executeForTargetModel";
		val parametersMap = <CorrespondingModelElementSpecification, JvmFormalParameter>newHashMap();
		CollectionBridge.mapFixed(createElements, 
				[parametersMap.put(it, targetModelElement.generateModelElementParameter(it))]);
		CollectionBridge.mapFixed(retrieveElements, 
				[parametersMap.put(it, targetModelElement.generateModelElementParameter(it))]);
		val beforeMethodsMap = <JvmFormalParameter, JvmOperation>newHashMap();
		CollectionBridge.mapFixed(retrieveElements, 
				[beforeMethodsMap.put(parametersMap.get(it), generateMethodGetCorrespondingModelElements(it, targetModelElement, true))]);
		
		val modelElementList = #[targetModelElement] + createElements + retrieveElements;
		val changeParameter = targetModelElement.generateChangeParameter();
		val blackboardParameter = targetModelElement.generateBlackboardParameter();
		val targetModelParameter = targetModelElement.eContainer().generateModelElementParameter(targetModelElement);
		val JvmOperation performResponseMethod = if (hasExecutionBlock) {
			generateMethodPerformResponse(response.effects.codeBlock, modelElementList);
		} else {
			null;
		}
		
		val afterCodeMap = <JvmFormalParameter, StringConcatenationClient>newHashMap();
		CollectionBridge.mapFixed(createElements, 
				[afterCodeMap.put(parametersMap.get(it), generateCodeAddModelElementCorrespondence(it, changeParameter, blackboardParameter, parametersMap.get(it).name))]);
		CollectionBridge.mapFixed(retrieveElements, 
				[afterCodeMap.put(parametersMap.get(it), generateCodeDeleteElement(parametersMap.get(it).name))]);
		
		return getOrGenerateMethod(methodName, typeRef(Void.TYPE)) [
			visibility = JvmVisibility.PRIVATE;
			exceptions += typeRef(IOException);
			parameters += changeParameter;
			parameters += blackboardParameter;
			parameters += targetModelParameter;
			body = '''
				LOGGER.debug("Execute response " + this.getClass().getName() + " for model element " + «targetModelParameter.name» + "(«targetModelElement.elementType.element.name»)");
				«IF hasExecutionBlock»
					«FOR element : createElements»
						«generateCodeGenerateModelElement(element, parametersMap.get(element).name)»
					«ENDFOR»
					«FOR element : retrieveElements»
						«val param = parametersMap.get(element)»
						«val method = beforeMethodsMap.get(param)»
						«method.returnType» «param.name» = «method.simpleName»(«
							changeParameter.name», «blackboardParameter.name», «targetModelParameter.name»);
					«ENDFOR»
					«performResponseMethod.simpleName»(«changeParameter.name»«
						FOR modelElement : modelElementList BEFORE ', ' SEPARATOR ', '»«modelElement.name»«ENDFOR»);
					«FOR element : createElements»
						«afterCodeMap.get(parametersMap.get(element))»
					«ENDFOR»
					«FOR element : retrieveElements.filter(CorrespondingModelElementDelete)»
						«afterCodeMap.get(parametersMap.get(element))»
					«ENDFOR»
				«ENDIF»
			'''
		];
	}
	
	
	
	/**
	 * Generates: executeResponse
	 * 
	 * <p>Calls the response execution after checking preconditions for updating the determined target models.
	 * 
	 * <p>Methods parameters are:
	 * <li>1. change: the change event ({@link EChange})
	 * <li>2. blackboard: the {@link Blackboard} containing the {@link CorrespondenceInstance}
	 */
	private def dispatch StringConcatenationClient generateMethodExecuteResponseBody(ConcreteTargetModelUpdate modelRootUpdate, JvmFormalParameter changeParameter, JvmFormalParameter blackboardParameter) {
		if (!modelRootUpdate.identifyingElement.complete) {
			return '''''';
		}
		val deleteIdentifyingElement = modelRootUpdate.identifyingElement instanceof CorrespondingModelElementDelete;
		val determineTargetModelsMethod = generateMethodGetCorrespondingModelElements(modelRootUpdate.identifyingElement, null, false);
		val deleteElementCode = if (deleteIdentifyingElement) {
			generateCodeDeleteElement("_targetElement");
		}  else {
			null;
		}
		val executePerTargetModelMethod = generateMethodExecuteForTargetModel(modelRootUpdate.identifyingElement, modelRootUpdate.createElements.filter[complete], modelRootUpdate.retrieveElements.filter[complete]);
		val targetModelElementClass = modelRootUpdate.identifyingElement.elementType.javaClass
		return '''
			«Iterable»<«targetModelElementClass»> _targetModels = «determineTargetModelsMethod.simpleName»(«changeParameter.name», «blackboardParameter.name»);
			for («targetModelElementClass» _targetElement : _targetModels) {
				«executePerTargetModelMethod.simpleName»(«changeParameter.name», «blackboardParameter.name», _targetElement);
				«IF deleteIdentifyingElement»
					«deleteElementCode»
				«ENDIF»
			}
		'''
	}
	
	/**
	 * Generates: executeResponse
	 * 
	 * <p>Calls the response execution after checking preconditions for creating the target model.
	 * 
	 * <p>Methods parameters are:
	 * <li>1. change: the change event ({@link EChange})
	 * <li>2. blackboard: the {@link Blackboard} containing the {@link CorrespondenceInstance}
	 */
	private def dispatch StringConcatenationClient generateMethodExecuteResponseBody(ConcreteTargetModelCreate modelRootCreate, JvmFormalParameter changeParameter, JvmFormalParameter blackboardParameter) {
		if (!modelRootCreate.rootElement.complete) {
			return '''''';
		}
		val generateTargetModelMethod = generateMethodGenerateTargetModel(modelRootCreate);
		val executePerTargetModelMethod = generateMethodExecuteForTargetModel(modelRootCreate.rootElement, 
			modelRootCreate.createElements.filter[complete], #[]
		);
		return '''
			«generateCodeGenerateModelElement(modelRootCreate.rootElement, "_targetModel")»
			«executePerTargetModelMethod.simpleName»(«changeParameter.name», «blackboardParameter.name», _targetModel);
			«generateTargetModelMethod.simpleName»(«changeParameter.name», «blackboardParameter.name», _targetModel);
		'''
	}	
	
	
	/**
	 * Generates: executeResponse
	 * 
	 * <p>Calls the response execution after checking preconditions without a target model.
	 * 
	 * <p>Methods parameters are:
	 * <li>1. change: the change event ({@link EChange})
	 */
	private def StringConcatenationClient generateMethodExecuteResponseBody(JvmFormalParameter changeParameter, JvmFormalParameter blackboardParameter) {
		val JvmOperation performResponseMethod = if (hasExecutionBlock) {
			generateMethodPerformResponse(response.effects.codeBlock, #[]);
		} else {
			null;
		}
		return '''
			LOGGER.debug("Execute response " + this.getClass().getName() + " with no affected model");
			«IF hasExecutionBlock»
				«performResponseMethod.simpleName»(«changeParameter.name», «blackboardParameter.name»);
			«ENDIF»
		'''
	}
	
}