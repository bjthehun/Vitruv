package tools.vitruv.framework.vsum.views

import java.util.ArrayList
import java.util.Collection
import java.util.List
import org.eclipse.emf.ecore.ENamedElement

/**
 * Basic view selector for a view that represents a set of model elements.
 */
class BasicViewSelector implements ViewSelector {

    val ViewType owner
    protected val List<SelectableElement> selectableElements

    protected new(ViewType owner) {
        this.owner = owner
        selectableElements = new ArrayList
    }

    protected new(ViewType owner, Collection<ENamedElement> elements) {
        this(owner)
        elements.forEach[this.selectableElements.add(new SelectableElement(it))]
    }

    override size() {
        return selectableElements.size
    }

    override getElements() {
        return selectableElements.map[element]
    }

    override setSelected(int index, boolean value) {
        selectableElements.get(index).selected = value
    }

    override isSelected(int index) {
        return selectableElements.get(index).selected
    }

    override getSelectedElements() {
        return selectableElements.filter[selected == true].map[element]
    }

    override createView() {
        return owner.createView(this)
    }

    override getIndexOf(ENamedElement element) {
        for (i : 0 ..< size) {
            if(selectableElements.get(i).element.equals(element)) {
                return i
            }
        }
        throw new IllegalArgumentException("Element is not part of this selector.")
    }

    /**
     * Checks if at least one element is selected.
     */
    override isValid() {
        return selectableElements.filter[selected].size > 0
    }

}
