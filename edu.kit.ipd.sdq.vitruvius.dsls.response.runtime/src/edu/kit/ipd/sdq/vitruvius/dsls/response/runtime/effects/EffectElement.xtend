package edu.kit.ipd.sdq.vitruvius.dsls.response.runtime.effects

import edu.kit.ipd.sdq.vitruvius.dsls.response.runtime.structure.Loggable
import java.util.List
import org.eclipse.emf.ecore.EObject
import edu.kit.ipd.sdq.vitruvius.dsls.response.runtime.helper.CorrespondenceHelper
import edu.kit.ipd.sdq.vitruvius.framework.contracts.datatypes.CorrespondenceInstance
import edu.kit.ipd.sdq.vitruvius.framework.contracts.meta.correspondence.Correspondence
import java.util.Collections
import org.eclipse.emf.ecore.util.EcoreUtil

abstract class EffectElement extends Loggable {
	protected final EObject element;
	private final List<Pair<EObject, String>> newCorrespondingElements;
	private final List<EObject> oldCorrespondingElements;
	protected final CorrespondenceInstance<Correspondence> correspondenceInstance;
	protected boolean delete;
	
	public new(EObject element, CorrespondenceInstance<Correspondence> correspondenceInstance) {
		this.element = element;
		this.correspondenceInstance = correspondenceInstance;
		this.newCorrespondingElements = newArrayList;
		this.oldCorrespondingElements = newArrayList;
		this.delete = false;
	}
	
	public def void preProcess() {
		removeCorrespondences();
		if (delete) {
			delete();
		}
	}
	
	public def void postProcess() {
		addCorrespondences();
	}

	protected def void removeCorrespondences() {
		for (oldCorrespondingElement: oldCorrespondingElements) {
			CorrespondenceHelper.removeCorrespondencesBetweenElements(correspondenceInstance, 
				element, null, oldCorrespondingElement, null
			);
		}
		if (delete) {
			CorrespondenceHelper.removeCorrespondencesOfObject(correspondenceInstance, element, null);
		}
	}	
	
	protected def void addCorrespondences() {
		for (newCorrespondingElement: newCorrespondingElements) {
			CorrespondenceHelper.addCorrespondence(correspondenceInstance, 
				element, newCorrespondingElement.key, newCorrespondingElement.value
			);
		}
	}
	
	public def void updateTUID();
	
	public def void addCorrespondingElement(EObject newCorrespondingElement, String tag) {
		this.newCorrespondingElements += new Pair(newCorrespondingElement, tag);
	}
	
	public def void removeCorrespondingElement(EObject oldCorrespondingElement) {
		this.oldCorrespondingElements -= oldCorrespondingElement;
	}
	
	public def void setDelete() {
		this.delete = true;
	}
	
	protected def void delete() {
		if (element == null) {
			return;
		}
		if (element.eContainer() == null) {
			if (element.eResource() != null) {
				logger.debug("Deleting root object: " + element);
				element.eResource().delete(Collections.EMPTY_MAP);
			} else {
				logger.warn("The element to delete was already removed: " + element);
			}
		} else {
			logger.debug("Removing non-root object: " + element);
			EcoreUtil.remove(element);
		}
	}		
}