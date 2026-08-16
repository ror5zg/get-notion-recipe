(asdf:defsystem "get-notion-recipe"
  :description "料理レシピを保存しているNotionデータソースを取得し、レスポンスをJSONとして保存する"
  :version "0.1.0"
  :depends-on ("dexador"
               "shasht"
               "jonathan"
               "cl-dotenv")
  :serial t
  :components ((:module "src"
                :components
                ((:file "package")
                 (:file "main")))))
