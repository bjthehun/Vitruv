package tools.vitruv.dsls.reactions.builder

import tools.vitruv.dsls.reactions.reactionsLanguage.Routine
import tools.vitruv.dsls.reactions.reactionsLanguage.ReactionsLanguageFactory
import org.eclipse.emf.ecore.EClass
import tools.vitruv.dsls.mirbase.mirBase.MirBaseFactory
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.function.Consumer
import tools.vitruv.dsls.reactions.reactionsLanguage.RetrieveModelElement
import tools.vitruv.dsls.reactions.builder.FluentRoutineBuilder.ActionStatementBuilder
import static com.google.common.base.Preconditions.*
import tools.vitruv.dsls.reactions.builder.FluentRoutineBuilder.ActionBuilder
import tools.vitruv.dsls.reactions.reactionsLanguage.CreateModelElement
import tools.vitruv.dsls.reactions.reactionsLanguage.ActionStatement
import tools.vitruv.dsls.reactions.reactionsLanguage.CreateCorrespondence
import tools.vitruv.dsls.reactions.reactionsLanguage.RemoveCorrespondence
import tools.vitruv.dsls.reactions.reactionsLanguage.ExistingElementReference
import org.eclipse.xtext.common.types.JvmOperation
import static tools.vitruv.dsls.reactions.codegen.helper.ReactionsLanguageConstants.*
import org.eclipse.xtext.xbase.XbaseFactory
import org.eclipse.xtext.xbase.XExpression

class FluentRoutineBuilder extends FluentReactionSegmentChildBuilder {

	@Accessors(PACKAGE_GETTER)
	var Routine routine
	@Accessors(PACKAGE_GETTER)
	var requireOldValue = false
	@Accessors(PACKAGE_GETTER)
	var requireNewValue = false
	@Accessors(PACKAGE_GETTER)
	var requireAffectedEObject = false
	@Accessors(PACKAGE_GETTER)
	var requireAffectedValue = false
	var EClass valueType
	var EClass affectedObjectType

	package new(String routineName, FluentBuilderContext context) {
		super(context)
		this.routine = ReactionsLanguageFactory.eINSTANCE.createRoutine => [
			name = routineName
			input = ReactionsLanguageFactory.eINSTANCE.createRoutineInput
		]
	}

	override protected attachmentPreparation() {
		super.attachmentPreparation()
		checkState(routine.action !== null, "No action was set on this routine!")
		checkState((!requireOldValue && !requireNewValue && !requireAffectedValue) || valueType !== null,
			"Although required, there was no value type set on the «this»")
		checkState(!requireAffectedEObject ||
			affectedObjectType !== null, '''Although required, there was no affected object type set on the «this»''')
		if (requireOldValue) {
			addInputElement(CHANGE_OLD_VALUE_ATTRIBUTE, valueType)
		}
		if (requireNewValue) {
			addInputElement(CHANGE_NEW_VALUE_ATTRIBUTE, valueType)
		}
		if (requireAffectedEObject) {
			addInputElement(CHANGE_AFFECTED_ELEMENT_ATTRIBUTE, affectedObjectType)
		}
	}

	def package start() {
		new RoutineStartBuilder(this)
	}

	def private addInputElement(String parameterName, EClass type) {
		routine.input.modelInputElements += (MirBaseFactory.eINSTANCE.createNamedMetaclassReference => [
			name = parameterName
		]).reference(type)
	}

	def package setValueType(EClass type) {
		checkState(valueType === null || valueType ==
			type, '''The «this» already has the value type “«valueType»” set. It thus cannot be set to “«type»”!''')
		valueType = type
	}

	def package setAffectedElementType(EClass type) {
		checkState(affectedObjectType === null || affectedObjectType ==
			type, '''The «this» already has the affected element type “«valueType»” set. It thus cannot be set to “«type»”!''')
		affectedObjectType = type
	}

	static class MatcherOrActionBuilder extends ActionBuilder {

		private new(FluentRoutineBuilder builder) {
			super(builder)
		}

		def match(Consumer<UndecidedMatcherStatementBuilder> matchers) {
			val matcher = ReactionsLanguageFactory.eINSTANCE.createMatcher
			builder.routine.matcher = matcher
			val statementsBuilder = new UndecidedMatcherStatementBuilder(builder)
			matchers.accept(statementsBuilder)
			new ActionBuilder(builder)
		}
	}

	static class RoutineStartBuilder extends MatcherOrActionBuilder {

		private new(FluentRoutineBuilder builder) {
			super(builder)
		}

		def input(Consumer<InputBuilder> inputs) {
			inputs.accept(new InputBuilder(builder))
		}

	}

	static class InputBuilder {
		val extension FluentRoutineBuilder builder

		private new(FluentRoutineBuilder builder) {
			this.builder = builder
		}

		def void model(EClass eClass, String parameterName) {
			routine.input.modelInputElements += MirBaseFactory.eINSTANCE.createNamedMetaclassReference => [
				metaclass = eClass
				name = parameterName
			]
		}

		def void plain(Class<?> javaClass, String parameterName) {
			throw new RuntimeException("not yet implemented") // TODO
		}
	}

	static class RetrieveModelElementMatcherStatementBuilder {
		val extension FluentRoutineBuilder builder
		val RetrieveModelElement statement

		private new(FluentRoutineBuilder builder, RetrieveModelElement statement) {
			this.builder = builder
			this.statement = statement
		}

		def retrieve(EClass modelElement) {
			statement.reference(modelElement)
			new RetrieveModelElementMatcherStatementCorrespondenceBuilder(builder, statement)
		}

		def retrieveOptional(EClass modelElement) {
			statement.optional = true
			retrieve(modelElement)
		}

	}

	static class RetrieveModelElementMatcherStatementCorrespondenceBuilder {
		val extension FluentRoutineBuilder builder
		val RetrieveModelElement statement

		private new(FluentRoutineBuilder builder, RetrieveModelElement statement) {
			this.builder = builder
			this.statement = statement
		}

		def correspondingTo() {
			new RetrieveModelElementMatcherStatementCorrespondenceElementBuilder(builder, statement)
		}

		def void correspondingTo(String element) {
			statement.correspondenceSource = correspondingElement(element)
		}
	}

	static class RetrieveModelElementMatcherStatementCorrespondenceElementBuilder {
		val extension FluentRoutineBuilder builder
		val RetrieveModelElement statement

		private new(FluentRoutineBuilder builder, RetrieveModelElement statement) {
			this.builder = builder
			this.statement = statement
		}

		def void affectedEObject() {
			builder.requireAffectedEObject = true
			statement.correspondenceSource = correspondingElement(CHANGE_AFFECTED_ELEMENT_ATTRIBUTE)
		}
	}

	static class UndecidedMatcherStatementBuilder {
		val extension FluentRoutineBuilder builder

		private new(FluentRoutineBuilder builder) {
			this.builder = builder
		}

		def vall(String valName) {
			val statement = ReactionsLanguageFactory.eINSTANCE.createRetrieveModelElement => [
				name = valName
			]
			builder.routine.matcher.matcherStatements += statement
			new RetrieveModelElementMatcherStatementBuilder(builder, statement)
		}

		def void requireAbsenceOf(EClass absentMetaclass) {
			val statement = (ReactionsLanguageFactory.eINSTANCE.createRetrieveModelElement => [
				abscence = true
			]).reference(absentMetaclass)
			builder.routine.matcher.matcherStatements += statement
		}
	}

	static class ActionBuilder {
		protected val extension FluentRoutineBuilder builder

		private new(FluentRoutineBuilder builder) {
			this.builder = builder
		}

		def action(Consumer<ActionStatementBuilder> actions) {
			this.builder.routine.action = ReactionsLanguageFactory.eINSTANCE.createAction
			val statementBuilder = new ActionStatementBuilder(builder)
			actions.accept(statementBuilder)
			readyToBeAttached = true
			return builder
		}
	}

	static class ActionStatementBuilder {
		val extension FluentRoutineBuilder builder

		private new(FluentRoutineBuilder builder) {
			this.builder = builder
		}

		def delete(String existingElement) {
			val statement = ReactionsLanguageFactory.eINSTANCE.createDeleteModelElement => [
				element = existingElement(existingElement)
			]
			builder.routine.action.actionStatements += statement
		}

		def vall(String vallName) {
			val statement = ReactionsLanguageFactory.eINSTANCE.createCreateModelElement => [
				name = vallName
			]
			builder.routine.action.actionStatements += statement
			new CreateStatementBuilder(builder, statement)
		}

		def addCorrespondenceBetween() {
			val statement = ReactionsLanguageFactory.eINSTANCE.createCreateCorrespondence
			builder.routine.action.actionStatements += statement
			new CorrespondenceElementBuilder(builder, new CorrespondenceTargetBuilder(builder, statement), [
				statement.firstElement = it
			])
		}

		def addCorrespondenceBetween(String existingElement) {
			val statement = ReactionsLanguageFactory.eINSTANCE.createCreateCorrespondence => [
				firstElement = existingElement(existingElement)
			]
			builder.routine.action.actionStatements += statement
			new CorrespondenceTargetBuilder(builder, statement)
		}

		def removeCorrespondenceBetween() {
			val statement = ReactionsLanguageFactory.eINSTANCE.createRemoveCorrespondence
			builder.routine.action.actionStatements += statement
			new CorrespondenceElementBuilder(builder, new CorrespondenceTargetBuilder(builder, statement), [
				statement.firstElement = it
			])
		}

		def removeCorrespondenceBetween(String existingElement) {
			val statement = ReactionsLanguageFactory.eINSTANCE.createRemoveCorrespondence => [
				firstElement = existingElement(existingElement)
			]
			builder.routine.action.actionStatements += statement
			new CorrespondenceTargetBuilder(builder, statement)
		}
	}

	static class CreateStatementBuilder {
		val extension FluentRoutineBuilder builder
		val CreateModelElement statement

		private new(FluentRoutineBuilder builder, CreateModelElement statement) {
			this.builder = builder
			this.statement = statement
		}

		def create(EClass element) {
			statement.reference(element)
			new CreateStatementIntializationBuilder(builder, statement)
		}
	}

	static class CreateStatementIntializationBuilder {
		val extension FluentRoutineBuilder builder
		val CreateModelElement statement

		private new(FluentRoutineBuilder builder, CreateModelElement statement) {
			this.builder = builder
			this.statement = statement
		}

		def andInitializeWith() {
			// TODO
		}
	}

	static class CorrespondenceElementBuilder<NextType> {
		val extension FluentRoutineBuilder builder
		val Consumer<ExistingElementReference> elementConsumer
		val NextType next

		private new(FluentRoutineBuilder builder, NextType next, Consumer<ExistingElementReference> elementConsumer) {
			this.builder = builder
			this.elementConsumer = elementConsumer
			this.next = next
		}

		def oldValue() {
			builder.requireOldValue = true
			elementConsumer.accept(existingElement(CHANGE_OLD_VALUE_ATTRIBUTE))
			next
		}

		def newValue() {
			builder.requireNewValue = true
			elementConsumer.accept(existingElement(CHANGE_NEW_VALUE_ATTRIBUTE))
			next
		}

		def affectedEObject() {
			builder.requireAffectedEObject = true
			elementConsumer.accept(existingElement(CHANGE_AFFECTED_ELEMENT_ATTRIBUTE))
			next
		}
	}

	static class CorrespondenceTargetBuilder {
		val extension FluentRoutineBuilder builder
		val ActionStatement statement

		private new(FluentRoutineBuilder builder, ActionStatement statement) {
			this.builder = builder
			this.statement = statement
		}

		def and() {
			new CorrespondenceElementBuilder(builder, null, [statement.secondElement = it])
		}

		def and(String existingElement) {
			statement.secondElement = existingElement(existingElement)
		}

		def private dispatch setSecondElement(CreateCorrespondence correspondenceStatement,
			ExistingElementReference existingElement) {
			correspondenceStatement.secondElement = existingElement
		}

		def private dispatch setSecondElement(RemoveCorrespondence correspondenceStatement,
			ExistingElementReference existingElement) {
			correspondenceStatement.secondElement = existingElement
		}
	}

	def private existingElement(String name) {
		ReactionsLanguageFactory.eINSTANCE.createExistingElementReference => [
			code = XbaseFactory.eINSTANCE.createXFeatureCall.whenJvmTypes [
				feature = correspondingMethodParameter(name)
			]
		]
	}

	def private correspondingElement(String name) {
		ReactionsLanguageFactory.eINSTANCE.createCorrespondingObjectCodeBlock => [
			code = XbaseFactory.eINSTANCE.createXFeatureCall.whenJvmTypes [
				feature = correspondingMethodParameter(name)
			]
		]
	}

	override toString() {
		'''routine builder for “«routine.name»”'''
	}

	def private correspondingMethodParameter(XExpression correpondingExpression, String parameterName) {
		val retrievalMethod = context.jvmModelAssociator.getPrimaryJvmElement(correpondingExpression)
		if (retrievalMethod instanceof JvmOperation) {
			val result = retrievalMethod.parameters.findFirst[name == parameterName]
			if (result === null) {
				throw new IllegalStateException('''Could not find the right parameter on the retrieval method for the element reference “«parameterName»” in the routine “«routine.name»”''')
			}
			return result
		}
		throw new IllegalStateException('''Could not find the retrieval method corresponding to the element reference “«parameterName»” in the routine “«routine.name»”''')
	}

	def package getJvmOperation() {
		val jvmMethod = context.jvmModelAssociator.getPrimaryJvmElement(routine)
		if (jvmMethod instanceof JvmOperation) {
			return jvmMethod
		}
		throw new IllegalStateException('''Could not find the routine facade method corresponding to the routine “«routine.name»”''')
	}

}