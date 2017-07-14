<!DOCTYPE html>
<html lang="en">
 <head>
  <title>Bike Rental System</title>
  <link rel="stylesheet" type="text/css" href="css/responsive.css">
 </head>
<body>

<section class="">
 <section class="caption">
  <h2 class="caption" style="text-align: center">BIKES FOR RENT</h2>
 </section>
</section>


<section class="search">
 <div class="wrapper">
 <div id="fom">
   <form method="post">
	<h3 style="text-align:center; color: #1512b7; font-weight:bold;">ADD BIKE CATEGORY</h3>
	<table height="100" align="center">
	<tr>
	  <td>Bike Category:</td>
	  <td><input name="bike_category" required></td>
	</tr>
	<tr>
	  <td>Cost per day:</td>
	  <td><input name="cost_per_day" required></td>
	</tr>
	<tr>
	  <td>Late fee per hour:</td>
	  <td><input name="late_fee" required></td>
	</tr>
	<tr>
	  <td style="text-align:center;"><input type="submit" name="add_new" value="Add"></td>
	</tr>
	</table>
   </form>
   <?php
	if(isset($_POST['add_new'])){

	$categ = $_POST['bike_category'];
        $cost = $_POST['cost_per_day'];
	$late = $_POST['late_fee'];
	$q = "INSERT INTO BIKE_CATEGORY VALUES('$categ','$cost','$late');";
 	
  	$dbhost = 'localhost';
	$con = mysqli_connect('localhost','root','root','bike_rental');
	if (!($con))
	{
	  echo "<script type = \"text/javascript\">alert(\"Failed to connect to MySQL database. Please check the connection and try again.\");
	    </script>";
	}

	mysqli_query($con,$q);
	mysqli_close($con);
	
	echo "<script type = \"text/javascript\">alert(\"Bike_category ", $categ, " was successfully added.\");
	</script>";
	}
    ?>
    <form method="post">
	<h3 style="text-align:center; color: #1512b7; font-weight:bold;">DELETE BIKE CATEGORY</h3>
	<table height="100" align="center">
	<tr>
	  <td>Bike Category:</td>
	  <td><input name="bike_category_existing" required></td>
	</tr>
	<tr>
	  <td style="text-align:center;"><input type="submit" name="delete" value="Delete"></td>
	</tr>
	</table>
   </form>
   <?php
	if(isset($_POST['delete'])){

	$categ = $_POST['bike_category_existing'];
        $q_check = "SELECT * FROM BIKE_CATEGORY WHERE CATEGORY_NAME = '$categ';";
        $q = "DELETE FROM BIKE_CATEGORY WHERE CATEGORY_NAME = '$categ';";
 	
  	$dbhost = 'localhost';
	$con = mysqli_connect('localhost','root','root','bike_rental');

	if (!($con))
	{
	  echo "<script type = \"text/javascript\">alert(\"Failed to connect to MySQL database. Please check the connection and try again.\");
	    </script>";
	}
        else{
          $r = mysqli_query($con,$q_check);
          $row = mysqli_fetch_assoc($r);
          if(!$row['COST_PER_DAY']){
            echo "<script type = \"text/javascript\">alert(\"Bike category ", $categ, " does not exist.\");
	   </script>";
          }
	  else{
            mysqli_query($con,$q);
            mysqli_close($con);
	
	    echo "<script type = \"text/javascript\">alert(\"Bike_category ", $categ, " was successfully removed.\");
	    </script>";
            }
          }
	}
    ?>
    <form method="post">
	<h3 style="text-align:center; color: #1512b7; font-weight:bold;">RENAME BIKE CATEGORY</h3>
	<table height="100" align="center">
	<tr>
	  <td>Old Bike Category:</td>
	  <td><input name="bike_category_old" required></td>
	</tr>
        <tr>
	  <td>New Bike Category:</td>
	  <td><input name="bike_category_new" required></td>
	</tr>
	<tr>
	  <td style="text-align:center;"><input type="submit" name="rename" value="Rename"></td>
	</tr>
	</table>
    </form>
    <?php
	if(isset($_POST['rename'])){

	$old_categ = $_POST['bike_category_old'];
	$new_categ = $_POST['bike_category_new'];

        $q_check = "SELECT * FROM BIKE_CATEGORY WHERE CATEGORY_NAME = '$old_categ';";
        $q = "UPDATE BIKE_CATEGORY SET CATEGORY_NAME = '$new_categ' WHERE CATEGORY_NAME = '$old_categ';";
 	
  	$dbhost = 'localhost';
	$con = mysqli_connect('localhost','root','root','bike_rental');

	if (!($con))
	{
	  echo "<script type = \"text/javascript\">alert(\"Failed to connect to MySQL database. Please check the connection and try again.\");
	    </script>";
	}
        else{
          $r = mysqli_query($con,$q_check);
          $row = mysqli_fetch_assoc($r);
          if(!$row['COST_PER_DAY']){
            echo "<script type = \"text/javascript\">alert(\"Bike category ", $old_categ, " does not exist.\");
	   </script>";
          }
	  else{   
	    mysqli_query($con,$q);
	    mysqli_close($con);
	
	    echo "<script type = \"text/javascript\">alert(\"Bike_category ", $old_categ, " was successfully renamed to ", $new_categ, ".\");
	    </script>";
            }
          }
	}
    ?>
    <form method="post">
	<h3 style="text-align:center; color: #1512b7; font-weight:bold;">QUERY BIKE CATEGORY</h3>
	<table height="100" align="center">
	<tr>
	  <td>Bike Category:</td>
	  <td><input name="bike_category_query" required></td>
	</tr>
        <tr>
	  <td style="text-align:center;"><input type="submit" name="query" value="Query"></td>
	</tr>
	</table>
    </form>
    <?php
	if(isset($_POST['query'])){

	$categ = $_POST['bike_category_query'];
	$q = "SELECT * FROM BIKE_CATEGORY WHERE CATEGORY_NAME = '$categ';";
	 	
  	$dbhost = 'localhost';
	$con = mysqli_connect('localhost','root','root','bike_rental');

	if (!($con))
	{
	  echo "<script type = \"text/javascript\">alert(\"Failed to connect to MySQL database. Please check the connection and try again.\");
	    </script>";
	}
	else{
	  $r = mysqli_query($con,$q);
	  $row = mysqli_fetch_assoc($r);
          mysqli_close($con);

          if(!$row['COST_PER_DAY']){
            echo "<script type = \"text/javascript\">alert(\"Bike category ", $categ, " does not exist.\");
	   </script>";
          }
	  else{
	    echo "<script type = \"text/javascript\">alert(\"For category ", $categ, ", the cost per day is ", $row['COST_PER_DAY'], " dollars and the late fee per hour is ", $row['LATE_FEE_PER_HOUR'], " dollars.\");
	    </script>";
            }
	  }
        }
    ?>
 </section>

</body>
</html>
