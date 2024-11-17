Rails.application.routes.draw do
  get "new_1511679", to: "files#new_1511679"
  post "new_1511679", to: "files#new_1511679"
  post "upload_1511679", to: "files#upload_1511679"

  root "files#new_1511679"

end
