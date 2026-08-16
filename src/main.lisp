(in-package :get-notion-recipe)

;; .envの読み込み
(cl-dotenv:load-env #P".env")

;; 定数の設定
(defparameter *api-key* (uiop:getenv "NOTION_API_KEY"))
(defparameter *json-path* (uiop:getenv "RECIPE_JSON_PATH"))
(defparameter *data-src-id* "32be0ebb-24b5-801a-bacf-000be14cf091")
(defparameter *api-version* "2026-03-11")
(defparameter *page-size* 100)

;; 関数定義
(defun save-pretty-json (json-string output-path)
  "レスポンスのJSONを整形してファイルに保存する"
  (let ((json-data (shasht:read-json json-string)))
    (with-open-file (out output-path
                         :direction :output
                         :if-exists :supersede
                         :if-does-not-exist :create
                         :external-format :utf-8)
      (shasht:write-json* json-data
                          :stream out
                          :pretty t
                          :indent-string "  "))))

(defun get-datasource-record (page-size)
  "Notionのデータソースからレコードを取得する"
  (multiple-value-bind (body status headers uri)
      (dex:post (format nil "https://api.notion.com/v1/data_sources/~A/query" *data-src-id*)
                :bearer-auth *api-key*
                :headers (list (cons "Notion-Version" *api-version*)
                               (cons "Content-Type" "application/json"))
                :content (jonathan:to-json (list :|page_size| page-size)))
    (format nil "Body: ~A~%Status: ~A~%Headers: ~A~%URI: ~A~%" body status headers uri)
    (save-pretty-json body *json-path*)))

;; メイン処理
(defun main ()
  (get-datasource-record *page-size*))
