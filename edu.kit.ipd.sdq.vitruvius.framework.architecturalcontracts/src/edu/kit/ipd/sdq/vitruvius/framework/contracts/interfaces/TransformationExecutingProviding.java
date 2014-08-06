package edu.kit.ipd.sdq.vitruvius.framework.contracts.interfaces;

import edu.kit.ipd.sdq.vitruvius.framework.contracts.datatypes.Change;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.datatypes.SyncTransformation;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.datatypes.VURI;

public interface TransformationExecutingProviding {
    // TODO: check whether we need the method getSyncTransformation
    @Deprecated
    public SyncTransformation getSyncTransformation(VURI mmURI1, Change change, VURI mmURI2);

    public EMFModelTransformationExecuting getTransformationExecuting(VURI mmURI1, VURI mmURI2);
}
