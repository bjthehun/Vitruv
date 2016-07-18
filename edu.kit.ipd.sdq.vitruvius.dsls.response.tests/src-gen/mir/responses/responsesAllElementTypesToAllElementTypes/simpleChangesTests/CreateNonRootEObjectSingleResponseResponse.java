package mir.responses.responsesAllElementTypesToAllElementTypes.simpleChangesTests;

import allElementTypes.NonRoot;
import allElementTypes.Root;
import edu.kit.ipd.sdq.vitruvius.dsls.response.runtime.AbstractResponseRealization;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.interfaces.UserInteracting;
import edu.kit.ipd.sdq.vitruvius.framework.meta.change.EChange;
import edu.kit.ipd.sdq.vitruvius.framework.meta.change.feature.reference.containment.CreateNonRootEObjectSingle;
import org.eclipse.emf.ecore.EObject;

@SuppressWarnings("all")
class CreateNonRootEObjectSingleResponseResponse extends AbstractResponseRealization {
  public CreateNonRootEObjectSingleResponseResponse(final UserInteracting userInteracting) {
    super(userInteracting);
  }
  
  public static Class<? extends EChange> getExpectedChangeType() {
    return CreateNonRootEObjectSingle.class;
  }
  
  private boolean checkChangeProperties(final CreateNonRootEObjectSingle<NonRoot> change) {
    EObject changedElement = change.getOldAffectedEObject();
    // Check model element type
    if (!(changedElement instanceof Root)) {
    	return false;
    }
    
    // Check feature
    if (!change.getAffectedFeature().getName().equals("singleValuedContainmentEReference")) {
    	return false;
    }
    return true;
  }
  
  public boolean checkPrecondition(final EChange change) {
    if (!(change instanceof CreateNonRootEObjectSingle<?>)) {
    	return false;
    }
    CreateNonRootEObjectSingle typedChange = (CreateNonRootEObjectSingle)change;
    if (!checkChangeProperties(typedChange)) {
    	return false;
    }
    getLogger().debug("Passed precondition check of response " + this.getClass().getName());
    return true;
  }
  
  public void executeResponse(final EChange change) {
    CreateNonRootEObjectSingle<NonRoot> typedChange = (CreateNonRootEObjectSingle<NonRoot>)change;
    mir.routines.simpleChangesTests.CreateNonRootEObjectSingleResponseEffect effect = new mir.routines.simpleChangesTests.CreateNonRootEObjectSingleResponseEffect(this.executionState, this, typedChange);
    effect.applyRoutine();
  }
}
