module Elasticity

  class EMR

    def initialize(aws_access_key_id, aws_secret_access_key)
      @aws_request = Elasticity::AwsRequest.new(aws_access_key_id, aws_secret_access_key)
    end

    # Lists all jobflows in all states.
    def describe_jobflows
      aws_result = @aws_request.aws_emr_request({"Operation" => "DescribeJobFlows"})
      xml_doc = Nokogiri::XML(aws_result)
      xml_doc.remove_namespaces!
      yield aws_result if block_given?
      JobFlow.from_members_nodeset(xml_doc.xpath("/DescribeJobFlowsResponse/DescribeJobFlowsResult/JobFlows/member"))
    end

    # Terminate the specified jobflow.  Amazon does not define a return value
    # for this operation, so you'll need to poll #describe_jobflows to see
    # the state of the jobflow.  Raises ArgumentError if the specified job
    # flow does not exist.
    def terminate_jobflows(jobflow_id)
      begin
        aws_result = @aws_request.aws_emr_request({
          "Operation" => "TerminateJobFlows",
          "JobFlowIds.member.1" => jobflow_id
        })
        yield aws_result if block_given?
      rescue RestClient::BadRequest
        raise ArgumentError, "Job flow '#{jobflow_id}' does not exist."
      end
    end

    # Pass the specified params hash directly through to the AWS request
    # URL.  Use this if you want to perform an operation that hasn't yet
    # been wrapped by Elasticity or you just want to see the response
    # XML for yourself :)
    def direct(params)
      @aws_request.aws_emr_request(params)
    end

  end
end
