provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  region       = var.region
}

resource "oci_core_instance" "this" {

  count = var.sever_count

  availability_config {
    recovery_action = "RESTORE_INSTANCE"
  }
  availability_domain = var.availability_domain
  fault_domain        = var.fault_domain
  compartment_id      = var.compartment_ocid
  create_vnic_details {
    assign_private_dns_record = "true"
    assign_public_ip          = var.assign_public_ipaddress
    subnet_id                 = var.subnet_ocid
  }
  display_name = "${var.display_name_prefix}_Server-${count.index + 1}"
  instance_options {
    are_legacy_imds_endpoints_disabled = "false"
  }
  is_pv_encryption_in_transit_enabled = "true"
  metadata = {
    ssh_authorized_keys = "${file(var.ssh_public_key)}"
    #ssh_authorized_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDxhuZDoN9YsfnJTesKEzcJUOsrX8ONDPEq8Jr3QQ1xKXOCMFBzTWw0+RoitQxZ48Rk/04rhZIveGTrQR9Z8j5CidFuyBunvMUTxkgX4MCdNTcaC9yliGKnvvcCFlnQrwawslLVAoo5Rr6OQ4VGCZDbO02oX8YwyHevKkgN22rlcf7HEimm9gIsbE+WOtUnXbavtTClIcQRGyRC6wGiVzPFGywAC0UTs5k480kKG1BGhNED9dsSJPE8DHg7bxQUeZFOg92foRRylO8XAtEjBtM/yGFmDImkmUjs+TVnzcXgsOP4BRA2+EdXHZTHOKei/bPG4NoTeX4MqpoT7qCeVbN5 mail2maham@572cd40cb779"
  }
  shape = var.instance_shape
  source_details {
    source_id   = var.image_ocid
    source_type = "image"
  }
}



resource "null_resource" "webapp-installer" {
  depends_on = [oci_core_instance.this]
  count      = var.sever_count

  connection {
    agent       = false
    timeout     = "30m"
    host        = oci_core_instance.this[count.index].public_ip
    user        = "opc"
    private_key = file(var.ssh_private_key)
  }


  provisioner "remote-exec" {
    inline = [
      "echo \"Module 1: ################################\"",
      "echo \"Module 1: # Configure Web Application    #\"",
      "echo \"Module 1: ################################\"",
      "echo ",
      "echo \"Step 0: Cpopy Tensor Flow Aminated Gif FIle from Download to /var/www/html/images\"",
      "cd /var/www/html/images/",
      "ls -ltr",
      "ls -ltr /home/opc/downloads",
      "ls -ltr",
      "cd /var/www/html/images/",
      "ls -ltr",
      "sudo wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/gdOP88Ti7aauETToPvURrObjA2Z9pE1519yygV5inQhO0puxbLu97w3vAEL7m-sA/n/orasenatdpltintegration03/b/webserver_images/o/tensorflowdemo.gif",
      "ls -ltr",
      "echo \"Step 1: Clean previousely installed application components\"",
      "cd /var/www/html/scripts/",
      "ls -ltr",
      "echo \"Step 2: Check the current index.html\"",
      "echo \"====> Check if index.html exisits **************\"",
      "cd /var/www/html",
      "ls -ltr ",
      "cat index.html",
      "sudo rm index.html",
      "ls -ltr ",
      "echo \"Step 3: Check if the script file exists\"",
      "cd /var/www/html/scripts",
      "ls -ltr ",
      "cat create_website_index_html.sh",
      "echo",
      "echo \"====> Run the scripts to create or update the app install **************\"",
      "echo",
      "sudo chmod +x create_website_index_html.sh",
      "sudo bash create_website_index_html.sh",
      "echo",
      "echo \"====> Check the content of the new index.html **************\"",
      "cat /var/www/html/index.html",
      "echo \"====> Resart the Apache Web server *********************\"",
      "sudo systemctl stop httpd",
      "sudo systemctl start httpd",
      "echo \"====> Public IP Address:\"",
      "curl ifconfig.co",
      "echo ",
      "echo \"====> Go to the brower and enter http:\\Public IP Address:\"",
      "echo ",
      "echo \"Module 1: ########################################\"",
      "echo \"Module 1: # Application Configuration Completed. #\"",
      "echo \"Module 1: ########################################\"",
    ]
  }
}
