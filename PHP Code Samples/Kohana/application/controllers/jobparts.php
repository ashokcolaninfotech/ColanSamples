<?php defined('SYSPATH') OR die('No direct access allowed.');
 
class Jobparts_Controller extends Genericobject_Controller{
		
	public function __construct()
	{

		$fields = array(
			"Id" => "jpart_id",
			"Name" => "jpart_partname",
			"Number" => "jpart_partnumber",
			"Model" => "jpart_partmodel",
			"UofM" => "jpart_partuofm",
			"Qty" => "jpart_qty",
			"Cost" => "jpart_cost",
			"Price" => "jpart_sellprice",
		);
		
		parent::__construct(new Jobpart_Model,'jobpart_edit','model_index',$fields,"jpart_partname",'ASC');
	}

	function add($id=0,$parenttable='',$parentid=0,$callback='')
	{
		utilities::setreturncallback($callback,'tab-parts');
		$this->edit(0,$parenttable,$parentid);
	}
	
	function edit($id,$parenttable='',$parentid=0,$callback='')
	{
		utilities::setreturncallback($callback,'tab-parts');
	
		$db = Database::instance('company');
		$model = new Jobpart_Model($id);

		$warehouses = Invwarehouse_Model::getAll($db);
	
		$parts = array();
		$strSQL = "SELECT part_id FROM parts ORDER BY part_name ASC";
		$query = $db->query($strSQL,array($id));
		foreach($query AS $item){
			$parts[] = new Part_Model($item->part_id);
		}
		$view = new View('jobpart_edit');
		$view->model= $model;	
		$view->parenttable = $parenttable;
		$view->parentid = $parentid;
		$view->parts = $parts;
		$view->warehouses = $warehouses;
		$view->render(TRUE);
	}	
	
	public function save(){
		//set correct values if I'm assigned a parent
	
		$_POST['jpart_jobid'] = $_POST['_parentid'];
		
		if ($this->input->post("_id") > 0) {
			parent::save('/jobparts/edit/'.$this->input->post("_id"));
                        
		} else {
			parent::save('',$_POST['jpart_jobid'],'add');
		}
	}

    public function getList($search,$method=NULL)
    {
        $db = Database::instance('company');
        $parts = array();
		$strSQL = "SELECT part_id AS id,CONCAT(part_name,'-',part_model,'-',part_number ) AS name,part_number FROM parts WHERE LOWER(part_name) LIKE ? ORDER BY part_name ASC";
		$query = $db->query($strSQL, array('%' . $search . '%'));
		foreach($query as $item){
            $parts[] = array(
                'name'  => $item->name,
                'id'    => $item->id,
                'part_number'    => $item->part_number
            );
        }
        
        if($method == "in")
        {
            $parts[] = array(
                'name'  => "All Parts",
                'id'    => "all",
                'part_number'    => "All Parts"
            );
        }

        echo json_encode(array('items' => $parts));
    }
    public function getnamepart($id)
    {
        $db = Database::instance('company');
        $partname = '';
		$strSQL = "SELECT part_id AS id,CONCAT(part_name,'-',part_model,'-',part_number ) AS name,part_number FROM parts WHERE part_id = ? ORDER BY part_name ASC";
		$query = $db->query($strSQL, array($id));
		foreach($query as $item){
             $partname = str_replace('"', ' ', $item->name);
            
        }

        echo $partname;
    }
    
}
