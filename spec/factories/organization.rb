FactoryBot.define do
  factory :organization do
    name "example"
    slug "localhost"
    default_account_filter '{"account_filter":"FL17"}'
    lms_authentication_source ""
    lms_authentication_key "yvB_xU1U-1f4OKnKiVqDHhtz1X6Wd24MGSBQ8hyK"
    lms_authentication_id "0oafpot97ww0kHpui0h7"

  end
end
# https://dev-396343.oktapreview.com/oauth2/default/v1/authorize?response_type=code&client_id=0oafpot97ww0kHpui0h7&redirect_uri=https://www.oauth.com/playground/authorization-code.html&scope=photo+offline_access&state=UhzRcW0-qzJSQQ5Y
#
# POST https://dev-396343.oktapreview.com/oauth2/default/v1/token
# grant_type=authorization_code
# &client_id=0oafpot97ww0kHpui0h7&client_secret=yvB_xU1U-1f4OKnKiVqDHhtz1X6Wd24MGSBQ8hyK
# &redirect_uri=https://www.oauth.com/playground/authorization-code.html
# &code=pVRuN2zmS-7RqU7cDL4n
#
# {
#   "access_token": "eyJraWQiOiIyRDN3Y0lycGQxYWpUdERwZ0NKTnFHU09odXNhQTVDUnEwRGd2ZGZXNXFVIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULmxzVlJySEl1cGNLS25kZ0lQaWw1RnV1aks1SEk3NkxtOWc3aG1jemVlRlkudkVtRHVwdHBXN3pMdEdhYzVESmsxbGh6WGJZaFg3dFY2QTltRDZsZWNNQT0iLCJpc3MiOiJodHRwczovL2Rldi0zOTYzNDMub2t0YXByZXZpZXcuY29tL29hdXRoMi9kZWZhdWx0IiwiYXVkIjoiYXBpOi8vZGVmYXVsdCIsImlhdCI6MTUzMTM0MjM0OSwiZXhwIjoxNTMxMzQ1OTQ5LCJjaWQiOiIwb2FmcG90OTd3dzBrSHB1aTBoNyIsInVpZCI6IjAwdWZwcDAwN3JLQ0V2UDJsMGg3Iiwic2NwIjpbIm9mZmxpbmVfYWNjZXNzIiwicGhvdG8iXSwic3ViIjoiZWFnZXItcGVsaWNhbkBleGFtcGxlLmNvbSJ9.AbyXrRA4hTfdj2MCEgZ4XHZDpIlqE6H0OUG6ltsxV3-nTx88OdtpKoySzs36M-ykysHH4BApqFuRnXO4AylWFeDHonrmQ246I50TBZ4jX6H0Z_OFspsMmRDoSo0U1MbTypb-6jjAIC3WaHuT2XsihI6xvH_ms_gvLwCDB6aP3VHO6LvNXAS2O3ctKdCKRkdQBastU6lfZQrj_EaOn0VgBJrLWjDdx8haPlI9tMAO17H6CQFLZ2rUr6vCcufAUQvyNCskVi_ThEeSInmRH2J6RHVwn6cIVCGWu-Sz3FwwZBQLhlcg7h87ju-AU3YpovGp-dNQnJLF70OVWgr4YHiUig",
#   "token_type": "Bearer",
#   "expires_in": 3600,
#   "scope": "offline_access photo",
#   "refresh_token": "VHGpv-yoeqHGAJFC7He6vg0EKs-YZPYD22_ZEabqz7o"
# }
