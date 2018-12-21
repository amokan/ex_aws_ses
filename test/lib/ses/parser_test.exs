defmodule ExAws.SES.ParserTest do
  use ExUnit.Case, async: true

  alias ExAws.SES.Parsers

  defp to_success(doc) do
    {:ok, %{body: doc}}
  end

  defp to_error(doc) do
    {:error, {:http_error, 403, %{body: doc}}}
  end

  test "#parse a verify_email_identity response" do
    rsp = """
      <VerifyEmailIdentityResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
      <VerifyEmailIdentityResult/>
        <ResponseMetadata>
          <RequestId>d8eb8250-be9b-11e6-b7f7-d570946af758</RequestId>
        </ResponseMetadata>
      </VerifyEmailIdentityResponse>
    """
    |> to_success


    {:ok, %{body: parsed_doc}} = Parsers.parse(rsp, :verify_email_identity)
    assert parsed_doc == %{request_id: "d8eb8250-be9b-11e6-b7f7-d570946af758"}
  end

  test "#parse a get_send_quota response" do
    rsp = """
      <GetSendQuotaResponse xmlns=\"http://ses.amazonaws.com/doc/2010-12-01/\">
        <GetSendQuotaResult>
          <Max24HourSend>200.0</Max24HourSend>
          <SentLast24Hours>0.0</SentLast24Hours>
          <MaxSendRate>1.0</MaxSendRate>
        </GetSendQuotaResult>
        <ResponseMetadata>
          <RequestId>12c706f8-0487-11e9-9129-897ed4cc1009</RequestId>
        </ResponseMetadata>
      </GetSendQuotaResponse>
    """
    |> to_success


    {:ok, %{body: parsed_doc}} = Parsers.parse(rsp, :get_send_quota)
    assert parsed_doc == %{ max_24_hour_send: 200.0, max_send_rate: 1.0, sent_last_24_hours: 0.0, request_id: "12c706f8-0487-11e9-9129-897ed4cc1009" }
  end

  test "#parse a get_send_statistics response" do
    rsp = """
    <GetSendStatisticsResponse xmlns=\"http://ses.amazonaws.com/doc/2010-12-01/\">
      <GetSendStatisticsResult>
        <SendDataPoints>
          <member>
            <Complaints>0</Complaints>
            <Rejects>0</Rejects>
            <Bounces>0</Bounces>
            <DeliveryAttempts>2</DeliveryAttempts>
            <Timestamp>2018-12-18T17:55:00Z</Timestamp>
          </member>
          <member>
            <Complaints>0</Complaints>
            <Rejects>0</Rejects>
            <Bounces>0</Bounces>
            <DeliveryAttempts>5</DeliveryAttempts>
            <Timestamp>2018-12-18T18:10:00Z</Timestamp>
          </member>
          <member>
            <Complaints>0</Complaints>
            <Rejects>0</Rejects>
            <Bounces>0</Bounces>
            <DeliveryAttempts>2</DeliveryAttempts>
            <Timestamp>2018-12-16T18:55:00Z</Timestamp>
          </member>
          <member>
            <Complaints>0</Complaints>
            <Rejects>0</Rejects>
            <Bounces>0</Bounces>
            <DeliveryAttempts>2</DeliveryAttempts>
            <Timestamp>2018-12-16T19:10:00Z</Timestamp>
          </member>
          <member>
            <Complaints>0</Complaints>
            <Rejects>0</Rejects>
            <Bounces>0</Bounces>
            <DeliveryAttempts>4</DeliveryAttempts>
            <Timestamp>2018-12-17T20:10:00Z</Timestamp>
          </member>
        </SendDataPoints>
      </GetSendStatisticsResult>
      <ResponseMetadata>
        <RequestId>e7ccb0d6-048a-11e9-bc84-65c13fca9f09</RequestId>
      </ResponseMetadata>
    </GetSendStatisticsResponse>
    """
    |> to_success

    {:ok, %{body: parsed_doc}} = Parsers.parse(rsp, :get_send_statistics)
    assert parsed_doc == %{request_id: "e7ccb0d6-048a-11e9-bc84-65c13fca9f09", send_statistics: [%{bounces: 0, complaints: 0, delivery_attempts: 2, rejects: 0, timestamp: "2018-12-18T17:55:00Z"}, %{bounces: 0, complaints: 0, delivery_attempts: 5, rejects: 0, timestamp: "2018-12-18T18:10:00Z"}, %{bounces: 0, complaints: 0, delivery_attempts: 2, rejects: 0, timestamp: "2018-12-16T18:55:00Z"}, %{bounces: 0, complaints: 0, delivery_attempts: 2, rejects: 0, timestamp: "2018-12-16T19:10:00Z"}, %{bounces: 0, complaints: 0, delivery_attempts: 4, rejects: 0, timestamp: "2018-12-17T20:10:00Z"}]}
  end


  test "#parse identity_verification_attributes" do
    rsp = """
      <GetIdentityVerificationAttributesResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
        <GetIdentityVerificationAttributesResult>
          <VerificationAttributes>
            <entry>
              <key>example.com</key>
              <value>
                <VerificationToken>pwCRTZ8zHIJu+vePnXEa4DJmDyGhjSS8V3TkzzL2jI8=</VerificationToken>
                <VerificationStatus>Pending</VerificationStatus>
              </value>
            </entry>
            <entry>
              <key>user@example.com</key>
              <value>
                <VerificationStatus>Pending</VerificationStatus>
              </value>
            </entry>
          </VerificationAttributes>
        </GetIdentityVerificationAttributesResult>
        <ResponseMetadata>
          <RequestId>f5e3ef21-bec1-11e6-b618-27019a58dab9</RequestId>
        </ResponseMetadata>
      </GetIdentityVerificationAttributesResponse>
    """
    |> to_success

    verification_attributes = %{
      "example.com" => %{
        verification_token: "pwCRTZ8zHIJu+vePnXEa4DJmDyGhjSS8V3TkzzL2jI8=",
        verification_status: "Pending"
      },
      "user@example.com" => %{
        verification_status: "Pending"
      }
    }


    {:ok, %{body: parsed_doc}} = Parsers.parse(rsp, :get_identity_verification_attributes)
    assert parsed_doc[:verification_attributes] == verification_attributes
  end

  test "#parse identity_list" do
    rsp = """
    <ListIdentitiesResponse xmlns=\"http://ses.amazonaws.com/doc/2010-12-01/\">
      <ListIdentitiesResult>
        <Identities>
          <member>foo.com</member>
          <member>foo.bar</member>
          <member>testdomain.co</member>
        </Identities>
      </ListIdentitiesResult>
      <ResponseMetadata>
        <RequestId>2350f2e7-0554-11e9-adc3-ffbd87899b73</RequestId>
      </ResponseMetadata>
    </ListIdentitiesResponse>
    """
    |> to_success

    {:ok, %{body: parsed_doc}} = Parsers.parse(rsp, :list_identities)
    assert parsed_doc == %{request_id: "2350f2e7-0554-11e9-adc3-ffbd87899b73", identities: ["foo.com", "foo.bar", "testdomain.co"]}
  end

  test "#parse configuration_sets" do
    rsp = """
      <ListConfigurationSetsResponse xmlns=\"http://ses.amazonaws.com/doc/2010-12-01/\">
        <ListConfigurationSetsResult>
          <ConfigurationSets>
            <member>
              <Name>test</Name>
            </member>
          </ConfigurationSets>
          <NextToken>QUFBQUF</NextToken>
        </ListConfigurationSetsResult>
        <ResponseMetadata>
          <RequestId>c177d6ce-c1b0-11e6-9770-29713cf492ad</RequestId>
        </ResponseMetadata>
      </ListConfigurationSetsResponse>
    """
    |> to_success

    configuration_sets = %{
      members: ["test"],
      next_token: "QUFBQUF"
    }

    {:ok, %{body: parsed_doc}} = Parsers.parse(rsp, :list_configuration_sets)
    assert parsed_doc[:configuration_sets] == configuration_sets
  end

  test "#parse send_email" do
    rsp = """
    <SendEmailResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
      <SendEmailResult>
        <MessageId>0100015914b22075-7a4e3573-ca72-41ce-8eda-388f81232ad9-000000</MessageId>
      </SendEmailResult>
      <ResponseMetadata>
        <RequestId>8194094b-c58a-11e6-b49d-838795cc7d3f</RequestId>
      </ResponseMetadata>
    </SendEmailResponse>
    """
    |> to_success

    {:ok, %{body: parsed_doc}} = Parsers.parse(rsp, :send_email)
    assert parsed_doc == %{
      request_id: "8194094b-c58a-11e6-b49d-838795cc7d3f",
      message_id: "0100015914b22075-7a4e3573-ca72-41ce-8eda-388f81232ad9-000000"
    }
  end

  test "#parse send_templated_email" do
    rsp = """
    <SendTemplatedEmailResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
      <SendTemplatedEmailResult>
        <MessageId>0100015914b22075-7a4e3573-ca72-41ce-8eda-388f81232ad9-000000</MessageId>
      </SendTemplatedEmailResult>
      <ResponseMetadata>
        <RequestId>8194094b-c58a-11e6-b49d-838795cc7d3f</RequestId>
      </ResponseMetadata>
    </SendTemplatedEmailResponse>
    """
    |> to_success

    {:ok, %{body: parsed_doc}} = Parsers.parse(rsp, :send_templated_email)
    assert parsed_doc == %{
      request_id: "8194094b-c58a-11e6-b49d-838795cc7d3f",
      message_id: "0100015914b22075-7a4e3573-ca72-41ce-8eda-388f81232ad9-000000"
    }
  end

  test "#parse a delete_identity response" do
    rsp = """
      <DeleteIdentityResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
        <DeleteIdentityResult/>
        <ResponseMetadata>
          <RequestId>88c79dfb-1472-11e7-94c4-4d1ecf50b91f</RequestId>
        </ResponseMetadata>
      </DeleteIdentityResponse>
    """
    |> to_success


    {:ok, %{body: parsed_doc}} = Parsers.parse(rsp, :delete_identity)
    assert parsed_doc == %{request_id: "88c79dfb-1472-11e7-94c4-4d1ecf50b91f"}
  end

  test "#parse a set_identity_notification_topic response" do
    rsp = """
      <SetIdentityNotificationTopicResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
        <SetIdentityNotificationTopicResult/>
        <ResponseMetadata>
          <RequestId>3d3f811a-1484-11e7-b9b1-db4762b6c4db</RequestId>
        </ResponseMetadata>
      </SetIdentityNotificationTopicResponse>
    """
    |> to_success


    {:ok, %{body: parsed_doc}} = Parsers.parse(rsp, :set_identity_notification_topic)
    assert parsed_doc == %{request_id: "3d3f811a-1484-11e7-b9b1-db4762b6c4db"}
  end

  test "#parse a set_identity_feedback_forwarding_enabled response" do
    rsp = """
      <SetIdentityFeedbackForwardingEnabledResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
        <SetIdentityFeedbackForwardingEnabledResult/>
        <ResponseMetadata>
          <RequestId>f1cc8133-149a-11e7-91a5-ed1259cbd185</RequestId>
        </ResponseMetadata>
      </SetIdentityFeedbackForwardingEnabledResponse>
    """
    |> to_success


    {:ok, %{body: parsed_doc}} = Parsers.parse(rsp, :set_identity_feedback_forwarding_enabled)
    assert parsed_doc == %{request_id: "f1cc8133-149a-11e7-91a5-ed1259cbd185"}
  end

  test "#parse a set_identity_headers_in_notifications_enabled response" do
    rsp = """
      <SetIdentityHeadersInNotificationsEnabledResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
        <SetIdentityHeadersInNotificationsEnabledResult/>
        <ResponseMetadata>
          <RequestId>01b49b78-30ca-11e7-948a-399bafb173a2</RequestId>
        </ResponseMetadata>
      </SetIdentityHeadersInNotificationsEnabledResponse>"
    """
    |> to_success


    {:ok, %{body: parsed_doc}} = Parsers.parse(rsp, :set_identity_headers_in_notifications_enabled)
    assert parsed_doc == %{request_id: "01b49b78-30ca-11e7-948a-399bafb173a2"}
  end

  test "#parse error" do
    rsp = """
      <ErrorResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
        <Error>
          <Type>Sender</Type>
          <Code>MalformedInput</Code>
          <Message>Top level element may not be treated as a list</Message>
        </Error>
        <RequestId>3ac0a9e8-bebd-11e6-9ec4-e5c47e708fa8</RequestId>
      </ErrorResponse>
    """
    |> to_error


    {:error, {:http_error, 403, err}} = Parsers.parse(rsp, :get_identity_verification_attributes)

    assert "Sender" == err[:type]
    assert "MalformedInput" == err[:code]
    assert "Top level element may not be treated as a list" == err[:message]
    assert "3ac0a9e8-bebd-11e6-9ec4-e5c47e708fa8" == err[:request_id]
  end
end
