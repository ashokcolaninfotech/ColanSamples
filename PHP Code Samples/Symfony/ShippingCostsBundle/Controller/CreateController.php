<?php

namespace ShippingCostsBundle\Controller;

use Common\Bundle\Forms\ShippingCosts\cxWizardShippingCostsData;
use Common\Bundle\Forms\ShippingCosts\cxWizardShippingCostsForm;
use Symfony\Component\HttpFoundation\Request;
use Caelix\Tools\cxWizard;
use Caelix\Tools\cxConst;

class CreateController extends HomeController
{

  /**************************************************************************************************************************************************/
  /******* Shipping Costs Wizard ********************************************************************************************************************/
  /**************************************************************************************************************************************************/

  public function wizardInitAction()
  {
    $data = array();
    $data['warehouse_name'] = '';
    $data['supplier_name'] = '';
    $data['pricing_levels'] = '1';
    $data['shipping_product_type_id'] = '';

    $wizard = new cxWizard($data);
    $wizard->page_count = 4;
    $this->getUser()->setClassObject($wizard, cxConst::WIZARD_CREATE_SHIPPING_COST);
    return $this->redirect($this->generateUrl('shipping_costs_create_wizard', array('page_num' => 1)));
  }

  public function wizardAction(Request $request, $page_num)
  {
    $wizard = $this->getUser()->getClassObject(cxConst::WIZARD_CREATE_SHIPPING_COST);
    $wizard->page_num = $page_num;

    $data = new cxWizardShippingCostsData($this->getCargo());
    $data->setWizard($wizard);
    $form = $this->createForm(new cxWizardShippingCostsForm($this->getCargo()), $data);
    $form->handleRequest($request);

    if (($form->isValid()) and ($data->save($form))) {
      if ($data->isCompleted()) {
        return $this->redirect($this->generateUrl('shipping_costs_home'));
      } else {
        return $this->redirect($this->generateUrl('shipping_costs_create_wizard', array('page_num' => $data->getNextPage())));
      }
    }

    $breadcrumb = $this->get('caelix.breadcrumb');
    $breadcrumb->addLink('Shipping Costs', $this->generateUrl('shipping_costs_home'));
    $breadcrumb->setTitle('Select Warehouse');

    if ($page_num > 1) {
      $breadcrumb->addLink('Search Criteria', $this->generateUrl('shipping_costs_create_wizard', array('page_num' => 1)));
    }

    if ($page_num > 2) {
      $breadcrumb->addLink('Select Warehouse', $this->generateUrl('shipping_costs_create_wizard', array('page_num' => 1)));
    }

    if ($page_num > 3) {
      $breadcrumb->addLink('Select Supplier', $this->generateUrl('shipping_costs_create_wizard', array('page_num' => 2)));
    }

    $breadcrumb->setTitle('Add Shipping Costs');

    return $this->render('ShippingCostsBundle:Create/Wizard:index.html.twig', array('form' => $form->createView()));
  }

  public function wizardBackAction($page_num)
  {
    $wizard = $this->getUser()->getClassObject(cxConst::WIZARD_CREATE_SHIPPING_COST);
    $wizard->page_num = $page_num;
    $data = new cxWizardShippingCostsData($this->getCargo());
    $data->setWizard($wizard);
    return $this->redirect($this->generateUrl('shipping_costs_create_wizard', array('page_num' => $data->getBackPage())));
  }

  public function wizardCancelAction()
  {
    $this->getUser()->setClassObject(null, cxConst::WIZARD_CREATE_SHIPPING_COST);
    return $this->redirect($this->generateUrl('shipping_costs_home'));
  }

  /**************************************************************************************************************************************************/
  /**************************************************************************************************************************************************/
  /**************************************************************************************************************************************************/

}
