package edu.kit.ipd.sdq.vitruvius.framework.run.syncmanager;

import edu.kit.ipd.sdq.vitruvius.framework.contracts.datatypes.Change;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.datatypes.ChangeResult;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.interfaces.ModelProviding;

/**
 * Executes the concrete model change. A ConcreteChangeSynchronizer can hold another
 * ConcreteChangeSynchronizer to enable nested synchronization.
 *
 * @author Langhamm
 *
 */
abstract class ConcreteChangeSynchronizer {
    protected final ModelProviding modelProviding;
    private final ConcreteChangeSynchronizer concreteChangeSynchronizer;

    public ConcreteChangeSynchronizer(final ModelProviding modelProviding) {
        this.modelProviding = modelProviding;
        this.concreteChangeSynchronizer = null;
    }

    public ConcreteChangeSynchronizer(final ModelProviding modelProviding,
            final ConcreteChangeSynchronizer concreteChangeSynchronizer) {
        this.modelProviding = modelProviding;
        this.concreteChangeSynchronizer = concreteChangeSynchronizer;
    }

    protected ChangeResult syncChange(final Change change) {
        if (null != this.concreteChangeSynchronizer) {
            return this.concreteChangeSynchronizer.syncChange(change);
        }
        return synchronizeChange(change);
    }

    abstract ChangeResult synchronizeChange(Change change);
}
