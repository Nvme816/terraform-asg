
#!/bin/bash
set -e

yum update -y
yum install -y httpd

systemctl enable httpd
systemctl start httpd

cat > /var/www/html/index.html <<'EOF'
<html>
  <head><title>ASG Web</title></head>
  <body>
    <h1>ASG Apache is running</h1>
    <p>Deployed by Terraform user data</p>
  </body>
</html>
EOF
