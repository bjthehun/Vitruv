package tools.vitruv.dsls.commonalities.language.extensions

import org.eclipse.xtend.lib.annotations.Data
import tools.vitruv.dsls.commonalities.util.ClassUtil
import tools.vitruv.extensions.dslruntime.commonalities.operators.mapping.attribute.AttributeType

/**
 * Mirrors the information available from {@link AttributeType}.
 */
@Data
class AttributeTypeDescription {

	val boolean multiValued
	val String qualifiedTypeName

	// Returns null if the type is not found
	def Class<?> getType() {
		try {
			return ClassUtil.getClassForName(qualifiedTypeName)
		} catch (ClassNotFoundException exception) {
			return null
		}
	}
}
