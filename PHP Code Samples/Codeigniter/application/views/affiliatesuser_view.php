	<style type="text/css">

	::selection{ background-color: #E13300; color: white; }
	::moz-selection{ background-color: #E13300; color: white; }
	::webkit-selection{ background-color: #E13300; color: white; }


	body {
		background-color: #fff;
		argin: 40px;
		font: 13px/20px normal Helvetica, Arial, sans-serif;
		color: #4F5155;
	}

	a {
		color: #003399;
		background-color: transparent;
		font-weight: normal;
	}

	h1 {
		color: #444;
		background-color: transparent;
		border-bottom: 1px solid #D0D0D0;
		font-size: 19px;
		font-weight: normal;
		margin: 0 0 14px 0;
		padding: 14px 15px 10px 15px;
	}

	code {
		font-family: Consolas, Monaco, Courier New, Courier, monospace;
		font-size: 12px;
		background-color: #f9f9f9;
		border: 1px solid #D0D0D0;
		color: #002166;
		display: block;
		margin: 14px 0 14px 0;
		padding: 12px 10px 12px 10px;
	}

	#body{
		margin: 0 15px 0 15px;
	}
	
	p.footer{
		text-align: right;
		font-size: 11px;
		border-top: 1px solid #D0D0D0;
		line-height: 32px;
		padding: 0 10px 0 10px;
		margin: 20px 0 0 0;
	}
	
	#container{
		argin: 10px;
		border: 1px solid #D0D0D0;
		-webkit-box-shadow: 0 0 8px #D0D0D0;
	}
	
	table.form td{ font-size:12px; font-family:Arial, Helvetica, sans-serif; color:#000; padding:0 9px 12px 0}
table.form td input{ width:200px; font-size:12px; padding:5px 10px; border:1px solid #ccc;}
table.form td input.reg{ width:auto;}
table.form th { width:auto;text-align:right;padding-right:10px;}

	</style>

    <div class="clear"></div>
    <div class="width margin-a mar-midd">
    
<!--
<div id="container">
-->
	<h1>Please fill details to read free chapter</h1>

	<div id="body">
			
	

<table border="0" width="100%" cellpadding="0" cellspacing="0" class="form"> 
<?php // echo form_open("affiliatesuser/index/$aff_id"); ?>
<?php echo form_open("affiliatesuser/getdetails/$aff_id/$product_cat/$product_id"); ?>
<tr>
			<th valign="top">First name:</th>
			<td><input type="text" lass="inp-form" name="first_name" value="<?php echo set_value('first_name'); ?>"/>&nbsp;&nbsp;<?php echo form_error('first_name'); ?></td>
			<td></td>
		</tr>
		<tr>
			<th valign="top">Last name:</th>
			<td><input type="text" name="last_name" lass="inp-form" value="<?php echo set_value('last_name'); ?>" />&nbsp;&nbsp;<?php echo form_error('last_name'); ?></td>
			<td></td>
		</tr>
		<tr>
			<th valign="top">Email:</th>
			<td><input type="text" name="email" lass="inp-form" value="<?php echo set_value('email'); ?>"/>&nbsp;&nbsp;<?php echo form_error('email'); ?></td>
			<td>
			
			</td>
		</tr>
		
				<tr>
			<th valign="top">Facebook:</th>
			<td><input type="text" name="facebook" class="inp-form" value="<?php echo set_value('facebook'); ?>"/>&nbsp;&nbsp;<?php echo form_error('facebook'); ?></td>
			<td>
			
			</td>
		</tr>
		
		
		<tr>
			<th valign="top">Twitter:</th>
			<td><input type="text" name="twitter" class="inp-form" value="<?php echo set_value('twitter'); ?>"/>&nbsp;&nbsp;<?php echo form_error('twitter'); ?></td>
			<td>
			
			</td>
		</tr>
			
		<tr>
			<th valign="top">Affiliateid:</th>
			<td><input type="text" name="affiliate_id" id="affiliate_id" class="inp-form" value="<?php echo $aff_id; ?>"/></td>
			<td>
			
			</td>
		</tr>
		
				<tr>
			<th valign="top">ProductID:</th>
			<td><input type="text" name="affiliate_id" id="affiliate_id" class="inp-form" value="<?php echo $product_id; ?>"/></td>
			<td>
			
			</td>
		</tr>
		
				<tr>
			<th valign="top">product Cat:</th>
			<td><input type="text" name="affiliate_id" id="affiliate_id" class="inp-form" value="<?php echo $product_cat; ?>"/></td>
			<td>
			
			</td>
		</tr>
		
		
                <tr>
			<th valign="top">Phone Number:</th>
			<td><input type="text" name="phone_number" class="inp-form" value="<?php echo set_value('phone_number'); ?>"/>&nbsp;&nbsp;<?php echo form_error('phone_number'); ?></td>
		</tr>

            
		
		
		
			<tr>
		<th>&nbsp;</th>
		<td valign="top">
	<input type="button" value="No Thanks" class="form-submit" onClick="window.location.href='./affiliatesuserexit';" /> 
	<input type="submit" value="Continue" class="form-submit" />
	<!--<input type="reset" value="" class="form-reset"  />-->
		</td>
		<td></td>
	</tr>
</table>

</form>		
</div>
</div>
