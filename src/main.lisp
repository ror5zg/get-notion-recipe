(in-package :get-notion-recipe)

;; .envの読み込み(開発環境の場合のみ)
(let ((env-mode (uiop:getenv "ENV_MODE")))
  (when (and env-mode
             (string= env-mode "DEV"))
    (cl-dotenv:load-env #P".env")))

;; 定数の設定
(defparameter *api-key* (uiop:getenv "NOTION_API_KEY"))
(defparameter *api-version* (uiop:getenv "NOTION_API_VERSION"))
(defparameter *json-path* (uiop:getenv "RECIPE_JSON_PATH"))
(defparameter *data-src-id* (uiop:getenv "RECIPE_DATA_SOURCE_ID"))
(defparameter *page-size* (parse-integer (uiop:getenv "RECIPE_MAX_PAGE_SIZE")))

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
    (log:info "uri: ~A" uri)
    (log:info "status: ~A" status)
    (log:info "headers: ~A"  headers)
    (save-pretty-json body *json-path*)))

;; メイン処理
(defun main ()
  (get-datasource-record *page-size*))
