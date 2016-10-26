<?php

namespace ShippingCostsBundle\Controller;

use Caelix\Controllers\cxReportController;
use Common\Bundle\Forms\ShippingCosts\cxDeleteShippingCostData;
use Common\Bundle\Forms\ShippingCosts\cxDeleteShippingCostForm;
use Common\Bundle\Forms\ShippingCosts\cxReport3130ParamsData;
use Common\Bundle\Forms\ShippingCosts\cxReport3130ParamsForm;
use Common\Bundle\Forms\ShippingCosts\cxShippingCostData;
use Common\Bundle\Forms\ShippingCosts\cxUpdateShippingCostCollectionData;
use Common\Bundle\Forms\ShippingCosts\cxUpdateShippingCostCollectionForm;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Caelix\Controllers\cxValidUserInterface;
use Caelix\Tools\cxConst;

class HomeController extends cxReportController implements cxValidUserInterface
{

  public function getSystemTableId()
  {
    return cxConst::SYSTEM_TABLE_GLOBAL;
  }

  protected function getReportNum()
  {
    return 3130;
  }

  /**
   * @param int $id
   * @return cxShippingCostData
   */
  protected function getOwnerData($id)
  {
    $params = array();
    $params[] = $this->getUser()->individual_id;
    $params[] = $id;

    $owner = new cxShippingCostData($this->getCargo());
    $owner->query('CALL report_3131(?,?)', $params);

    return $owner;
  }

  public function indexAction(Request $request)
  {
    $params = array();
    $params[] = $this->getUser()->individual_id;

    $data = new cxReport3130ParamsData($this->getCargo());
    $data->query('CALL list_report_3130_params(?)', $params);
    $form = $this->createForm(new cxReport3130ParamsForm($this->getCargo()), $data);
    $form->handleRequest($request);

    if ($form->isValid()) {
      ($data->save($form));
    }

    $report = $this->get('caelix.report');
    $report->query('CALL report_3130(?)', $params);
    $report->setReportParams($data);

    $breadcrumb = $this->get('caelix.breadcrumb');
    $breadcrumb->setTitle('Shipping Costs');
    $breadcrumb->setReportParams($report->getReportParams());

    return $this->render('ShippingCostsBundle:Home:index.html.twig', array('form' => $form->createView(), 'report' => $report));
  }

  public function updateAction(Request $request)
  {
    $params = array();
    $params[] = $this->getUser()->individual_id;

    $data = new cxUpdateShippingCostCollectionData($this->getCargo());
    $data->query('CALL report_1060(?)', $params);
    $form = $this->createForm(new cxUpdateShippingCostCollectionForm($this->getCargo()), $data);
    $form->handleRequest($request);

    if (($form->isValid()) and ($data->save($form))) {
      $html = $this->renderView('ShippingCostsBundle:Home:table.html.twig', array('report'=>$this->getList()));
      return new JsonResponse(array('error'=>false, 'list'=>$html));
    }

    $html = $this->renderView('ShippingCostsBundle:Home:update.html.twig', array('form'=>$form->createView()));
    return new JsonResponse(array('error'=>($form->isSubmitted() and !$form->isValid()), 'form'=>$html));
  }

  public function deleteAction(Request $request, $id)
  {
    $owner = $this->getOwnerData($id);

    $data = new cxDeleteShippingCostData($this->getCargo());
    $data->assign($owner->data);
    $form = $this->createForm(new cxDeleteShippingCostForm($this->getCargo()), $data);
    $form->handleRequest($request);

    if (($form->isValid()) and ($data->save($form))) {
      $html = $this->renderView('ShippingCostsBundle:Home:table.html.twig', array('report'=>$this->getList()));
      return new JsonResponse(array('error'=>false, 'list'=>$html));
    }

    $html = $this->renderView('ShippingCostsBundle:Home:delete.html.twig', array('form'=>$form->createView()));
    return new JsonResponse(array('error'=>($form->isSubmitted() and !$form->isValid()), 'form'=>$html));
  }
  
  /********************************************************************************************************************/
  /******* Return the page report table and param html ****************************************************************/
  /********************************************************************************************************************/

  private function getList()
  {
    $params = array();
    $params[] = $this->getUser()->individual_id;

    $data = new cxReport3130ParamsData($this->getCargo());
    $data->query('CALL list_report_3130_params(?)', $params);

    $result = $this->getReport();
    $result->query('CALL report_3130(?)', $params);
    $result->setReportParams($data);

    return $result;
  }

  protected function getReportList()
  {
    $report = $this->getList();
    $breadcrumb = $this->get('caelix.breadcrumb');
    $breadcrumb->setReportParams($report->getReportParams());

    $report_params = $this->renderView('CommonBundle:Layout:report_params.html.twig', array('report' => $report));
    $report_table = $this->renderView('ShippingCostsBundle:Home:table.html.twig', array('report' => $report));

    return array('report_params' => $report_params, 'report_table' => $report_table);
  }

  /********************************************************************************************************************/
  /********************************************************************************************************************/
  /********************************************************************************************************************/

}
