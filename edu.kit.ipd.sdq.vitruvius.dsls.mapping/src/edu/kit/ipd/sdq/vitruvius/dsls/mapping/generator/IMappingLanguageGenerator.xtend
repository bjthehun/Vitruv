package edu.kit.ipd.sdq.vitruvius.dsls.mapping.generator

import edu.kit.ipd.sdq.vitruvius.dsls.response.responseLanguage.Response
import java.util.Collection
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator

interface IMappingLanguageGenerator extends IGenerator {
	def void initialize()
	def Collection<Response> generateAndCreateResponses(Collection<Resource> input, IFileSystemAccess fsa)
}