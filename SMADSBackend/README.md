# SMADSBackend
Code for backend deployment of the SMADs Project

## Production Server
### System Administrator
Max Svetlik, maxsvetlik@utexas.edu, @maxsvetlik on SMADs slack

## Deployment details
Up-to-date code* is currently being deployed on the following host:

    hypnotoad.csres.utexas.edu
    
and has the following relevant ports:

    :22   - SSH 
    :8085 - HTTP API Calls (when supported)
    :8043 - HTTPS API Calls
    :8087 - RESERVED - to be used for DB access when on UT VPN

*see Section: CI/CD

### SSL
The server now supports signed and verified SSL certificates through a certificate authority. 
Please configure your clients to use SSL when possible. The server retains the right to accept 
unencrypted traffic on `:8085` but will phase that out as soon as is feasible.


### CI/CD
When a new commit is pushed to the `master` branch of this repository, the server will automatically do the following

    1) stop deploying the SMADs backend
    2) pull the newest commit(s)
    3) attempt to redeploy the SMADs backend
    
while convenient, this makes it easy to push breaking code to the production server. If the code doesn't build after step 2, the server cannot redeploy the backend 
and will remain broken until manual intervention is done by the server's administrator.
