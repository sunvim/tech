# `Ankr KMS INSTRUCTION`



## `What is KMS`

> The `Ankr KMS`  origins problem domain which includes save static secrets and dynamic secrets.  the static secrets contains service's configuration information, encryption key, decryption key and so on, these information are usually not change but it's very sensitive and secret, so they should be saved in the `KMS`.  the other important part, dynamic secrets, it contains token generate(such as database access token generate), `PKI` service, `EaaS`(Encryption as a Service) and so on.



## `How to Use KMS`

- Part I: The Static Secrets

  1. store the static secrets into `KMS`

     > we supply two ways to solve this problem, the one is do it with our web manger system, the other one is do it with our official `SDK` 

     the below example is `SDK` way, the doc address is 

     [here]: https://godoc.org/github.com/Ankr-network/go-kms/kvdb	"go-kms"

     ```go
     // operaterAddr is remote kms operator service ,the default port is 8080
     // vaultAddr is remote kms vault service, the default port is 8200
     // ankr-sms is the app role
     kvc, err := NewKVer(operaterAddr, vaultAddr, "ankr-sms")
     if err != nil {
     	...
     }
     // hello is the store path
     // map[string]string{"hello": "world"} is the data
     if err = kvc.Put("hello", map[string]string{"hello": "world"}); err != nil {
        ...
     }
     ```

     

  2. 

- Part II: The Dynamic Secrets