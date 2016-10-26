<?php

class Affiliatesusermodel extends CI_Model {

    function __construct() {
        // Call the Model constructor
        parent::__construct();
    }

    function getAffiliate($id) {
        $data = array();
        $options = array('id' => id_clean($id));
        $Q = $this->db->get_where('tbl_affiliates', $options, 1);
        if ($Q->num_rows() > 0) {
            $data = $Q->row_array();
        }
        $Q->free_result();
        return $data;
    }

    function getAllAffiliates() {
        $data = array();
        $Q = $this->db->get('tbl_affiliates');
        if ($Q->num_rows() > 0) {
            foreach ($Q->result_array() as $row) {
                $data[] = $row;
            }
        }
        $Q->free_result();
        return $data;
    }

    function adduser() {

	$date_added = date('Y-m-d');
        $data = array(
            'first_name' => db_clean($_POST['first_name'], 50),
            'last_name' => db_clean($_POST['last_name'], 50),            
            'email' => db_clean($_POST['email'], 255),
            'facebook' => db_clean($_POST['facebook'], 255),
           'twitter' => db_clean($_POST['twitter'], 255),
           'phone_number' => db_clean($_POST['phone_number'], 255),
           'reg_date' => db_clean($date_added, 255),
           'affiliate_id' => db_clean($_POST['affiliate_id'], 255),
               
          );

        $this->db->insert('tbl_affiliates_users', $data);
    }


}

?>
