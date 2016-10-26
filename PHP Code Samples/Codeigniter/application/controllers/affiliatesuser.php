<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

class Affiliatesuser extends CI_Controller {

    /**
     * Index Page for this controller.
     *
     * Maps to the following URL
     * 		http://example.com/index.php/welcome
     * 	- or -  
     * 		http://example.com/index.php/welcome/index
     * 	- or -
     * Since this controller is set as the default controller in 
     * config/routes.php, it's displayed at http://example.com/
     *
     * So any other public methods not prefixed with an underscore will
     * map to /index.php/welcome/<method_name>
     * @see http://codeigniter.com/user_guide/general/urls.html
     */
    function Affiliatesuser() {
        parent::__construct();
        session_start();
        $this->load->helper(array('form', 'url'));
        $this->load->library('form_validation');
        $this->load->model('Affiliatesusermodel');
    }

    public function index($aff_id = 'direct', $product_cat = '', $product_id = '') {
        //echo $product_id;
        //echo $product_cat;
        //echo $aff_id;
        //exit;



        $data['aff_id'] = $aff_id;
        $data['product_id'] = $product_id;
        $data['product_cat'] = $product_cat;

        $this->load->view('header');
        $this->load->view('affiliatesuser_view', $data);
        $this->load->view('footer');
    }

    public function getdetails($aff_id = 'direct', $product_cat = '', $product_id = '') {


        $data['aff_id'] = $aff_id;
        $data['product_id'] = $product_id;
        $data['product_cat'] = $product_cat;
        $config = array(
            array(
                'field' => 'first_name',
                'label' => 'First name',
                'rules' => 'required'
            ),
            array(
                'field' => 'last_name',
                'label' => 'Last name',
                'rules' => 'required'
            ),
            array(
                'field' => 'email',
                'label' => 'Email',
                'rules' => 'required'
            ),
            array(
                'field' => 'email',
                'label' => 'Email',
                'rules' => 'required|valid_email'
            ),
            array(
                'field' => 'phone_number',
                'label' => 'Phone Number',
                'rules' => 'required'
            ),
        );

        $this->form_validation->set_error_delimiters('<span style="color:red;">', '</span>');
        $error = $this->form_validation->set_rules($config);
        if ($this->form_validation->run() == FALSE) {
            $this->load->view('header');
            $this->load->view('affiliatesuser_view', $data);
            $this->load->view('footer');
        } else {
            $this->Affiliatesusermodel->adduser();
            $this->session->set_flashdata('message', 'User added successfully ');
            redirect("sample/index/$aff_id/$product_cat/$product_id", 'refresh');
        }



        //    $this->Affiliatesusermodel->adduser();
    }

}

/* End of file welcome.php */
/* Location: ./application/controllers/welcome.php */
