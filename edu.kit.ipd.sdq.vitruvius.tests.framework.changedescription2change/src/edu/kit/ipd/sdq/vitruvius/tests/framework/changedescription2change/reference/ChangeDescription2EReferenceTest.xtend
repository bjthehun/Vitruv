package edu.kit.ipd.sdq.vitruvius.tests.framework.changedescription2change.reference

import edu.kit.ipd.sdq.vitruvius.tests.framework.changedescription2change.ChangeDescription2ChangeTransformationTest
import allElementTypes.NonRoot
import allElementTypes.AllElementTypesFactory

class ChangeDescription2EReferenceTest extends ChangeDescription2ChangeTransformationTest {
	
		
	def protected NonRoot createAndAddNonRootToRootMultiReference(int index) {
		val nonRoot = AllElementTypesFactory.eINSTANCE.createNonRoot
		this.rootElement.multiValuedContainmentEReference.add(index, nonRoot)
		return nonRoot
	}
	
	def protected NonRoot createAndSetNonRootToRootSingleReference() {
		val nonRoot = AllElementTypesFactory.eINSTANCE.createNonRoot
		this.rootElement.singleValuedContainmentEReference = nonRoot
		return nonRoot
	}
}