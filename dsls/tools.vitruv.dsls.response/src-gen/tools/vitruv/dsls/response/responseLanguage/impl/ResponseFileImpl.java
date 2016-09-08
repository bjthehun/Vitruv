/**
 * generated by Xtext 2.10.0
 */
package tools.vitruv.dsls.response.responseLanguage.impl;

import tools.vitruv.dsls.mirbase.mirBase.impl.MirBaseFileImpl;

import tools.vitruv.dsls.response.responseLanguage.ResponseFile;
import tools.vitruv.dsls.response.responseLanguage.ResponseLanguagePackage;
import tools.vitruv.dsls.response.responseLanguage.ResponsesSegment;

import java.util.Collection;

import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.common.notify.NotificationChain;

import org.eclipse.emf.common.util.EList;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.InternalEObject;

import org.eclipse.emf.ecore.impl.ENotificationImpl;

import org.eclipse.emf.ecore.util.EObjectContainmentEList;
import org.eclipse.emf.ecore.util.InternalEList;

import org.eclipse.xtext.xtype.XImportSection;

/**
 * <!-- begin-user-doc -->
 * An implementation of the model object '<em><b>Response File</b></em>'.
 * <!-- end-user-doc -->
 * <p>
 * The following features are implemented:
 * </p>
 * <ul>
 *   <li>{@link tools.vitruv.dsls.response.responseLanguage.impl.ResponseFileImpl#getNamespaceImports <em>Namespace Imports</em>}</li>
 *   <li>{@link tools.vitruv.dsls.response.responseLanguage.impl.ResponseFileImpl#getResponsesSegments <em>Responses Segments</em>}</li>
 * </ul>
 *
 * @generated
 */
public class ResponseFileImpl extends MirBaseFileImpl implements ResponseFile
{
  /**
   * The cached value of the '{@link #getNamespaceImports() <em>Namespace Imports</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getNamespaceImports()
   * @generated
   * @ordered
   */
  protected XImportSection namespaceImports;

  /**
   * The cached value of the '{@link #getResponsesSegments() <em>Responses Segments</em>}' containment reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getResponsesSegments()
   * @generated
   * @ordered
   */
  protected EList<ResponsesSegment> responsesSegments;

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  protected ResponseFileImpl()
  {
    super();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  protected EClass eStaticClass()
  {
    return ResponseLanguagePackage.Literals.RESPONSE_FILE;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public XImportSection getNamespaceImports()
  {
    return namespaceImports;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public NotificationChain basicSetNamespaceImports(XImportSection newNamespaceImports, NotificationChain msgs)
  {
    XImportSection oldNamespaceImports = namespaceImports;
    namespaceImports = newNamespaceImports;
    if (eNotificationRequired())
    {
      ENotificationImpl notification = new ENotificationImpl(this, Notification.SET, ResponseLanguagePackage.RESPONSE_FILE__NAMESPACE_IMPORTS, oldNamespaceImports, newNamespaceImports);
      if (msgs == null) msgs = notification; else msgs.add(notification);
    }
    return msgs;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public void setNamespaceImports(XImportSection newNamespaceImports)
  {
    if (newNamespaceImports != namespaceImports)
    {
      NotificationChain msgs = null;
      if (namespaceImports != null)
        msgs = ((InternalEObject)namespaceImports).eInverseRemove(this, EOPPOSITE_FEATURE_BASE - ResponseLanguagePackage.RESPONSE_FILE__NAMESPACE_IMPORTS, null, msgs);
      if (newNamespaceImports != null)
        msgs = ((InternalEObject)newNamespaceImports).eInverseAdd(this, EOPPOSITE_FEATURE_BASE - ResponseLanguagePackage.RESPONSE_FILE__NAMESPACE_IMPORTS, null, msgs);
      msgs = basicSetNamespaceImports(newNamespaceImports, msgs);
      if (msgs != null) msgs.dispatch();
    }
    else if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, ResponseLanguagePackage.RESPONSE_FILE__NAMESPACE_IMPORTS, newNamespaceImports, newNamespaceImports));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public EList<ResponsesSegment> getResponsesSegments()
  {
    if (responsesSegments == null)
    {
      responsesSegments = new EObjectContainmentEList<ResponsesSegment>(ResponsesSegment.class, this, ResponseLanguagePackage.RESPONSE_FILE__RESPONSES_SEGMENTS);
    }
    return responsesSegments;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public NotificationChain eInverseRemove(InternalEObject otherEnd, int featureID, NotificationChain msgs)
  {
    switch (featureID)
    {
      case ResponseLanguagePackage.RESPONSE_FILE__NAMESPACE_IMPORTS:
        return basicSetNamespaceImports(null, msgs);
      case ResponseLanguagePackage.RESPONSE_FILE__RESPONSES_SEGMENTS:
        return ((InternalEList<?>)getResponsesSegments()).basicRemove(otherEnd, msgs);
    }
    return super.eInverseRemove(otherEnd, featureID, msgs);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public Object eGet(int featureID, boolean resolve, boolean coreType)
  {
    switch (featureID)
    {
      case ResponseLanguagePackage.RESPONSE_FILE__NAMESPACE_IMPORTS:
        return getNamespaceImports();
      case ResponseLanguagePackage.RESPONSE_FILE__RESPONSES_SEGMENTS:
        return getResponsesSegments();
    }
    return super.eGet(featureID, resolve, coreType);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @SuppressWarnings("unchecked")
  @Override
  public void eSet(int featureID, Object newValue)
  {
    switch (featureID)
    {
      case ResponseLanguagePackage.RESPONSE_FILE__NAMESPACE_IMPORTS:
        setNamespaceImports((XImportSection)newValue);
        return;
      case ResponseLanguagePackage.RESPONSE_FILE__RESPONSES_SEGMENTS:
        getResponsesSegments().clear();
        getResponsesSegments().addAll((Collection<? extends ResponsesSegment>)newValue);
        return;
    }
    super.eSet(featureID, newValue);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void eUnset(int featureID)
  {
    switch (featureID)
    {
      case ResponseLanguagePackage.RESPONSE_FILE__NAMESPACE_IMPORTS:
        setNamespaceImports((XImportSection)null);
        return;
      case ResponseLanguagePackage.RESPONSE_FILE__RESPONSES_SEGMENTS:
        getResponsesSegments().clear();
        return;
    }
    super.eUnset(featureID);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public boolean eIsSet(int featureID)
  {
    switch (featureID)
    {
      case ResponseLanguagePackage.RESPONSE_FILE__NAMESPACE_IMPORTS:
        return namespaceImports != null;
      case ResponseLanguagePackage.RESPONSE_FILE__RESPONSES_SEGMENTS:
        return responsesSegments != null && !responsesSegments.isEmpty();
    }
    return super.eIsSet(featureID);
  }

} //ResponseFileImpl