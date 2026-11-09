
resource "aws_s3_bucket" "logs"{
    bucket = "webserver-logs"
}

resource "aws_s3_object" "access_log1"{
    bucket = aws_s3_bucket.logs.id
    key = "access-logs/log1.txt"
    content = <<EOF
    192.168.1.10 GET /index.html 200
    192.168.1.20 GET /login.html 200
    192.168.1.30 POST /login 401
    EOF
}

resource "aws_s3_object" "access_log2" {
    bucket = aws_s3_bucket.logs.id
    key = "access-logs/log2.txt"
    content = <<EOF
    192.168.1.10 GET /index.html 200
    192.168.1.20 GET /index.html 200
    192.168.1.30 POST /index 401
    EOF
}

