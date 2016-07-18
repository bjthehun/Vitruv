package mir.routines.simpleChangesTests;

import allElementTypes.NonRoot;
import allElementTypes.Root;
import com.google.common.base.Objects;
import edu.kit.ipd.sdq.vitruvius.dsls.response.runtime.AbstractEffectRealization;
import edu.kit.ipd.sdq.vitruvius.dsls.response.runtime.ResponseExecutionState;
import edu.kit.ipd.sdq.vitruvius.dsls.response.runtime.structure.CallHierarchyHaving;
import edu.kit.ipd.sdq.vitruvius.dsls.response.tests.simpleChangesTests.SimpleChangesTestsExecutionMonitor;
import edu.kit.ipd.sdq.vitruvius.framework.meta.change.feature.reference.RemoveNonContainmentEReference;
import java.io.IOException;
import java.util.function.Predicate;
import mir.routines.simpleChangesTests.RoutinesFacade;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.xbase.lib.Extension;

@SuppressWarnings("all")
public class RemoveNonContainmentEReferenceEffect extends AbstractEffectRealization {
  public RemoveNonContainmentEReferenceEffect(final ResponseExecutionState responseExecutionState, final CallHierarchyHaving calledBy, final RemoveNonContainmentEReference<NonRoot> change) {
    super(responseExecutionState, calledBy);
    				this.change = change;
  }
  
  private RemoveNonContainmentEReference<NonRoot> change;
  
  private EObject getCorrepondenceSourceTargetRoot(final RemoveNonContainmentEReference<NonRoot> change) {
    EObject _newAffectedEObject = change.getNewAffectedEObject();
    return _newAffectedEObject;
  }
  
  protected void executeRoutine() throws IOException {
    getLogger().debug("Called routine RemoveNonContainmentEReferenceEffect with input:");
    getLogger().debug("   RemoveNonContainmentEReference: " + this.change);
    
    Root targetRoot = getCorrespondingElement(
    	getCorrepondenceSourceTargetRoot(change), // correspondence source supplier
    	Root.class,
    	(Root _element) -> true, // correspondence precondition checker
    	null);
    if (targetRoot == null) {
    	return;
    }
    initializeRetrieveElementState(targetRoot);
    
    preprocessElementStates();
    new mir.routines.simpleChangesTests.RemoveNonContainmentEReferenceEffect.EffectUserExecution(getExecutionState(), this).executeUserOperations(
    	change, targetRoot);
    postprocessElementStates();
  }
  
  private static class EffectUserExecution extends AbstractEffectRealization.UserExecution {
    @Extension
    private RoutinesFacade effectFacade;
    
    public EffectUserExecution(final ResponseExecutionState responseExecutionState, final CallHierarchyHaving calledBy) {
      super(responseExecutionState);
      this.effectFacade = new mir.routines.simpleChangesTests.RoutinesFacade(responseExecutionState, calledBy);
    }
    
    private void executeUserOperations(final RemoveNonContainmentEReference<NonRoot> change, final Root targetRoot) {
      EList<NonRoot> _multiValuedNonContainmentEReference = targetRoot.getMultiValuedNonContainmentEReference();
      final Predicate<NonRoot> _function = (NonRoot it) -> {
        String _id = it.getId();
        NonRoot _oldValue = change.getOldValue();
        String _id_1 = _oldValue.getId();
        return Objects.equal(_id, _id_1);
      };
      _multiValuedNonContainmentEReference.removeIf(_function);
      SimpleChangesTestsExecutionMonitor _instance = SimpleChangesTestsExecutionMonitor.getInstance();
      _instance.set(SimpleChangesTestsExecutionMonitor.ChangeType.RemoveNonContainmentEReference);
    }
  }
}
