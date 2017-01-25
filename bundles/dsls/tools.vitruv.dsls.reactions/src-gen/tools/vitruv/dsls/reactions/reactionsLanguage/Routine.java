/**
 * generated by Xtext 2.10.0
 */
package tools.vitruv.dsls.reactions.reactionsLanguage;

import org.eclipse.emf.ecore.EObject;

/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>Routine</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * </p>
 * <ul>
 *   <li>{@link tools.vitruv.dsls.reactions.reactionsLanguage.Routine#getName <em>Name</em>}</li>
 *   <li>{@link tools.vitruv.dsls.reactions.reactionsLanguage.Routine#getInput <em>Input</em>}</li>
 *   <li>{@link tools.vitruv.dsls.reactions.reactionsLanguage.Routine#getMatcher <em>Matcher</em>}</li>
 *   <li>{@link tools.vitruv.dsls.reactions.reactionsLanguage.Routine#getAction <em>Action</em>}</li>
 *   <li>{@link tools.vitruv.dsls.reactions.reactionsLanguage.Routine#getReturn <em>Return</em>}</li>
 *   <li>{@link tools.vitruv.dsls.reactions.reactionsLanguage.Routine#getReactionsSegment <em>Reactions Segment</em>}</li>
 * </ul>
 *
 * @see tools.vitruv.dsls.reactions.reactionsLanguage.ReactionsLanguagePackage#getRoutine()
 * @model
 * @generated
 */
public interface Routine extends EObject
{
  /**
   * Returns the value of the '<em><b>Name</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Name</em>' attribute isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Name</em>' attribute.
   * @see #setName(String)
   * @see tools.vitruv.dsls.reactions.reactionsLanguage.ReactionsLanguagePackage#getRoutine_Name()
   * @model
   * @generated
   */
  String getName();

  /**
   * Sets the value of the '{@link tools.vitruv.dsls.reactions.reactionsLanguage.Routine#getName <em>Name</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Name</em>' attribute.
   * @see #getName()
   * @generated
   */
  void setName(String value);

  /**
   * Returns the value of the '<em><b>Input</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Input</em>' containment reference isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Input</em>' containment reference.
   * @see #setInput(RoutineInput)
   * @see tools.vitruv.dsls.reactions.reactionsLanguage.ReactionsLanguagePackage#getRoutine_Input()
   * @model containment="true"
   * @generated
   */
  RoutineInput getInput();

  /**
   * Sets the value of the '{@link tools.vitruv.dsls.reactions.reactionsLanguage.Routine#getInput <em>Input</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Input</em>' containment reference.
   * @see #getInput()
   * @generated
   */
  void setInput(RoutineInput value);

  /**
   * Returns the value of the '<em><b>Matcher</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Matcher</em>' containment reference isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Matcher</em>' containment reference.
   * @see #setMatcher(Matcher)
   * @see tools.vitruv.dsls.reactions.reactionsLanguage.ReactionsLanguagePackage#getRoutine_Matcher()
   * @model containment="true"
   * @generated
   */
  Matcher getMatcher();

  /**
   * Sets the value of the '{@link tools.vitruv.dsls.reactions.reactionsLanguage.Routine#getMatcher <em>Matcher</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Matcher</em>' containment reference.
   * @see #getMatcher()
   * @generated
   */
  void setMatcher(Matcher value);

  /**
   * Returns the value of the '<em><b>Action</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Action</em>' containment reference isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Action</em>' containment reference.
   * @see #setAction(Action)
   * @see tools.vitruv.dsls.reactions.reactionsLanguage.ReactionsLanguagePackage#getRoutine_Action()
   * @model containment="true"
   * @generated
   */
  Action getAction();

  /**
   * Sets the value of the '{@link tools.vitruv.dsls.reactions.reactionsLanguage.Routine#getAction <em>Action</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Action</em>' containment reference.
   * @see #getAction()
   * @generated
   */
  void setAction(Action value);

  /**
   * Returns the value of the '<em><b>Return</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Return</em>' containment reference isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Return</em>' containment reference.
   * @see #setReturn(ReturnStatement)
   * @see tools.vitruv.dsls.reactions.reactionsLanguage.ReactionsLanguagePackage#getRoutine_Return()
   * @model containment="true"
   * @generated
   */
  ReturnStatement getReturn();

  /**
   * Sets the value of the '{@link tools.vitruv.dsls.reactions.reactionsLanguage.Routine#getReturn <em>Return</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Return</em>' containment reference.
   * @see #getReturn()
   * @generated
   */
  void setReturn(ReturnStatement value);

  /**
   * Returns the value of the '<em><b>Reactions Segment</b></em>' container reference.
   * It is bidirectional and its opposite is '{@link tools.vitruv.dsls.reactions.reactionsLanguage.ReactionsSegment#getRoutines <em>Routines</em>}'.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Reactions Segment</em>' container reference isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Reactions Segment</em>' container reference.
   * @see #setReactionsSegment(ReactionsSegment)
   * @see tools.vitruv.dsls.reactions.reactionsLanguage.ReactionsLanguagePackage#getRoutine_ReactionsSegment()
   * @see tools.vitruv.dsls.reactions.reactionsLanguage.ReactionsSegment#getRoutines
   * @model opposite="routines" required="true" transient="false"
   * @generated
   */
  ReactionsSegment getReactionsSegment();

  /**
   * Sets the value of the '{@link tools.vitruv.dsls.reactions.reactionsLanguage.Routine#getReactionsSegment <em>Reactions Segment</em>}' container reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Reactions Segment</em>' container reference.
   * @see #getReactionsSegment()
   * @generated
   */
  void setReactionsSegment(ReactionsSegment value);

} // Routine
