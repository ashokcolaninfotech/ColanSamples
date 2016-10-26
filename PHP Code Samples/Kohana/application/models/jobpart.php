<?php defined('SYSPATH') or die('No direct script access.');
 
class Jobpart_Model extends Genericobject_Model {	
	public function __construct($id = NULL)
	{
		$this->jpart_qty = 1;

		parent::__construct('jobparts','jpart_id',$id,'company');
	}
	
	public function getcaption(){
		return $this->jpart_partname;
	}

	public function getparent(){
		$ret = NULL;
		if($this->jpart_jobid > 0){
			$ret = new Job_Model($this->jpart_jobid);
		}
		return $ret;
	}
	
	public function getprice(){
		$ret = $this->jpart_sellprice;
		return $ret;
	}
	
	public function getsubtotal(){
		$ret = 0;
		if($this->jpart_qty > 0){
			$ret = $this->getprice() * $this->jpart_qty;
		}
		return $ret;
	}
	
	public function save(){
		//see if our part id changed
		$jp = new Jobpart_Model($this->_id);
		if($jp->jpart_partid != $this->jpart_partid){
			$p = new Part_Model($this->jpart_partid);
			$this->jpart_partuofm = $p->part_uofm;
			$this->jpart_cost = $p->part_cost;
			$this->jpart_sellprice = $p->part_sellprice;
			$this->jpart_partname = $p->part_name;
			$this->jpart_partmodel = $p->part_model;
			$this->jpart_partnumber = $p->part_number;
		
		}
				
		parent::save();
	}

	/**
	 * Determine if a specific job has a job part based on the stocknumber. If we find one, return it. We
     * should not have to create a new job part, even if it is new to the job. STM should have taken care of it.
	 *
	 * @param $jobId
	 * @param $stocknumber
	 * @return Jobpart_Model
	 */
	public static function jobPartExists($jobId, $stocknumber) {
		$db = Database::instance('company');

		$sql = 'SELECT *
				FROM jobparts
				WHERE jpart_partnumber = ?
				AND jpart_jobid = ?';

		$result = $db->query($sql, array($stocknumber, $jobId))->current();

		if ($result) {
			return new Jobpart_Model($result->jpart_id);
		} else {
			return new Jobpart_Model();
		}
	}
}