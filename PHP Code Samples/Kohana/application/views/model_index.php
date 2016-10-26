<? require("templates/header.php"); ?>

<? if($this->session->get('message')){ ?> 
<div class="message">
	<?=$this->session->get('message');?>
</div>
<? } ?>
<br />

<script type="text/javascript">
	window.onload = function(){	
		new YAHOO.util.YUILoader({
			base: '<?php echo url::base(); ?>/resources/js/yui/',
		    require: ['button','container'],
		    		
		    onSuccess: function() {
		    <? if(sizeof($models) > 0){ ?>
				<? if(method_exists($models[0],'getimportfields')){ ?>
					<? if(sizeof($models[0]->getimportfields()) > 0){ ?>				
						var o_btn_import = new YAHOO.widget.Button("_import_button");
						o_btn_import.on("click", function(){
							window.location.href='/<?=Router::$controller?>/import/';
						}); 
					<? } ?>
				<? } ?>		
			<? } ?>
//				var o_btn_xls = new YAHOO.widget.Button("_xls_button");
//				o_btn_xls.on("click", function(){
//					window.location.href='/<?//=Router::$controller?>///toxls/';
//				});
				//form stuff
				var o_btn_filter = new YAHOO.widget.Button("_filter_button");
				o_btn_filter.on("click", function(){
					document.searchform.submit();
				}); 
                                <? $views = Gridview_Model::getviewsbyuserid($this->_user->id,Router::$controller,Router::$method); ?>
                                <? if(sizeof($views) > 0){ ?>
                                 //delete filter                            
                                 var o_btn_deletefilter_button = new YAHOO.widget.Button("_deletefilter_button");
                                o_btn_deletefilter_button.on("click", function(){
					deletefilter();
				});
                                <?php } ?>
				var o_btn_savefilter = new YAHOO.widget.Button("_savefilter_button");
				o_btn_savefilter.on("click", function(){
					savefilter('/<?=Router::$controller?>','<?=Router::$method?>')
				});					
	
			<? $search = $this->session->get('_search'); ?>
			<? if(is_array($search) && isset($search[Router::$controller.Router::$method])){ ?>
				<? for($i=0;$i<sizeof($search[Router::$controller.Router::$method]);$i++){ ?>
					var o_btn_clearfilter = new YAHOO.widget.Button("_clearfilter_button_<?=$i?>");
					o_btn_clearfilter.on("click", function(){
						document.getElementById('term_<?=$i?>').value=''
						document.searchform.submit();
					});
				<? } ?>
			<? } ?>
				
				var o_btn_add = new YAHOO.widget.Button("_addmodel_button");
				
				o_btn_add.on("click", function(){
					window.location='<?php echo url::base(); ?>//<?=Router::$controller?>/add';
				});
			}
		}).insert(); 
	}	
</script>


<div class="yui-skin-sam">

	<? require("templates/filter.php"); ?>
	<table class="grid">
	
		<tr>
			<th width="50">&nbsp;</th>
			<? foreach($fields AS $key=>$val){ ?>
				<?=utilities::orderbyth($val,$key) ?>
			<? } ?>
			<th align="center">
				<button id="_addmodel_button">Add New</button>			
				<?/* utilities::actionlink("add",$this->model,$this->uri)*/ ?>
			</th>
		</tr>
			
	<? $db = Database::instance('company'); if(is_array($models)){ ?>
		<? foreach($models AS $model){ ?>
			<tr>
				<td><a href="/<?=$model->_table?>/edit/<?=$model->_id?>"><div class="editbutton">Edit</div></a></td>
				<? foreach($fields AS $val){ 
                                    if($val=='stype_name'){
                                       $type_id = $model->staff_typeid; 
                                       
                                    $strSQL = "SELECT stype_name FROM stafftypes WHERE stype_id=?";
                                    $query_type = $db->query($strSQL,array($type_id));
                                    $results_type = $query_type->as_array(); 
                                    if(count($results_type)>0){
                                   ?><td><?=$results_type[0]->stype_name; ?></td>
                                       <?php } else {?> <td> </td><?php }} elseif($val=='part_category'){                                          
                                            $type_id = $model->part_category; 
                                            $cat_name = '';
                                            if($type_id!=0)
                                            {
                                                $strSQL = "SELECT name FROM lookups WHERE id =?";
                                                $query_type = $db->query($strSQL,array($type_id));
                                                $results_type = $query_type->as_array();
                                                $cat_name = $results_type[0]->name;
                                            }
                                           ?>
                                       <td><?=$cat_name; ?></td>
                                       <?php } else{
                                    ?>
					<td><?=$model->$val ?></td>
                                <? } }?>
				<td class="actiontd">
					<select name="action" onchange="doaction(this)" class="actioncombo">
						<option value="">Action</option>
						<option value="">-------</option>
						<option value="/<?=$model->_table?>/edit/<?=$model->_id?>">Edit</option>
						<option value="/<?=$model->_table?>/delete/<?=$model->_id?>">Delete</option>
					</select>
					<? /*
					<? utilities::actionlink("edit",$model,$this->uri) ?>
					<? utilities::actionlink("delete",$model,$this->uri) ?>
					*/?>
				</td>
			</tr>
		<? } ?>
	<? } ?>
	</table>
	<? require("templates/pages.php"); ?>

</div>




<? require("templates/footer.php"); ?>