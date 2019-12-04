# Vault create a new root token

Step 1:  generate `OTP`

```bash
commad: 
			vault operator generate-root -generate-otp
output:
		vYAzdgGP5d7a57lAqDlVY3XtqS
```



Step 2: 

```bash
vault operator generate-root  -init  -otp="vYAzdgGP5d7a57lAqDlVY3XtqS"

output:
		generate a root token in progress
```



Step 3: 

```bash
command:

	vault operator generate-root

output:

Operation nonce: 2998f296-aeca-2765-d86d-57dd6890aa58
Unseal Key (will be hidden): 
Nonce            2998f296-aeca-2765-d86d-57dd6890aa58
Started          true
Progress         3/3
Complete         true
Encoded Token    BXcsDFMlNgVCXVE3T0RcLCMhVD0jUAkxRRs
```



Step 4: Decode Root Token

```bash
command:

vault operator generate-root -decode="BXcsDFMlNgVCXVE3T0RcLCMhVD0jUAkxRRs"  -otp="vYAzdgGP5d7a57lAqDlVY3XtqS"

output:

   s.mv7BqUw9fVzs0mRe8kzcQE4H
```



Step 5: revoke root token

```bash
vault token revoke xxxx
```

