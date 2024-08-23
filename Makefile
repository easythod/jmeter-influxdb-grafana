define create_invalidation
    aws cloudfront create-invalidation --distribution-id $(1) --paths "/*"
endef

define add_ip_to_sg
	aws ec2 authorize-security-group-ingress --region eu-central-1 --group-id ${NANO_LB_SG_ID} --ip-permissions \
            '[{"IpProtocol": "tcp", "FromPort": 1080, "ToPort": 1080, \
            "IpRanges": [{"CidrIp": "$(1)", "Description": "added by ${BITBUCKET_REPO_SLUG} pipeline"}]}]'
endef

define remove_ip_from_sg
    aws ec2 revoke-security-group-ingress --region eu-central-1 --group-id ${NANO_LB_SG_ID} --ip-permissions \
    		'[{"IpProtocol": "tcp", "FromPort": 1080, "ToPort": 1080, \
    		"IpRanges": [{"CidrIp": "$(1)"}]}]'

endef

open_sq_rule:
	$(call add_ip_to_sg,${CURRENT_IP})

close_sq_rule:
	$(call remove_ip_from_sg,${CURRENT_IP})

invalidate_cache:
	$(call create_invalidation,${CLOUDFRONT_DISTRIBUTION_ID})

slack-notification-test:
	curl -s -X POST https://hooks.slack.com/services/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 \
	-H "content-type:application/json" \
    -d '{"text":"[${BITBUCKET_REPO_SLUG}]\n$(shell cat ./test_results/results_summary.txt)"}'

slack-notification:
	curl -s -X POST https://hooks.slack.com/services/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 \
	-H "content-type:application/json" \
    -d '{"text":"[${BITBUCKET_REPO_SLUG}]\n$(shell cat ./test_results/results_summary.txt)"}'