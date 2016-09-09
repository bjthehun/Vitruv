package tools.vitruv.framework.change.description.impl

import org.eclipse.emf.ecore.change.ChangeDescription
import tools.vitruv.framework.util.datatypes.VURI
import tools.vitruv.framework.change.description.EMFModelChange
import tools.vitruv.framework.change.preparation.ChangeToEChangeConverter

class EMFModelChangeImpl extends AbstractConcreteChange implements EMFModelChange {
	private final ChangeDescription changeDescription;

    public new(ChangeDescription changeDescription, VURI vuri) {
    	super(vuri);
        this.changeDescription = changeDescription;
    }

    override ChangeDescription getChangeDescription() {
        return this.changeDescription;
    }

    override String toString() {
        return EMFModelChange.getSimpleName() + ": VURI: " + this.URI + " EChange: " + this.changeDescription;
    }

	
	override prepare(ChangeToEChangeConverter converter) {
		this.eChanges.clear();
		this.eChanges.addAll(converter.calculateEChangesForChange(this));
		setPrepated();
	}		
}