package mir.responses.responsesAllElementTypesToAllElementTypes.simpleChangesTests;

import edu.kit.ipd.sdq.vitruvius.dsls.response.runtime.AbstractResponseRealization;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.interfaces.UserInteracting;
import edu.kit.ipd.sdq.vitruvius.framework.meta.change.EChange;
import edu.kit.ipd.sdq.vitruvius.framework.meta.change.feature.attribute.RemoveEAttributeValue;

@SuppressWarnings("all")
class RemoveEAttributeValueResponse extends AbstractResponseRealization {
  public RemoveEAttributeValueResponse(final UserInteracting userInteracting) {
    super(userInteracting);
  }
  
  public static Class<? extends EChange> getExpectedChangeType() {
    return RemoveEAttributeValue.class;
  }
  
  public boolean checkPrecondition(final EChange change) {
    if (!(change instanceof RemoveEAttributeValue<?>)) {
    	return false;
    }
    RemoveEAttributeValue typedChange = (RemoveEAttributeValue)change;
    getLogger().debug("Passed precondition check of response " + this.getClass().getName());
    return true;
  }
  
  public void executeResponse(final EChange change) {
    RemoveEAttributeValue<Integer> typedChange = (RemoveEAttributeValue<Integer>)change;
    mir.routines.simpleChangesTests.RemoveEAttributeValueEffect effect = new mir.routines.simpleChangesTests.RemoveEAttributeValueEffect(this.executionState, this);
    effect.setChange(typedChange);
    effect.applyEffect();
  }
}