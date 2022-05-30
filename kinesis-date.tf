resource "aws_kinesis_stream" "datastream-terraform" {
  name             = "datastream-terraform"
  shard_count      = 1
  retention_period = 300

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

}
