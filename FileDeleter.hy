(import [flask [Flask render_template]])
(import os)
(import time)
(import config)



(setv BASEDIR config.BASEDIR)
(setv DIR BASEDIR)

(defn getfile [file]
  (, file
     (time.ctime (os.path.getmtime file))
     (os.path.isdir file)))

(defn dispfile [file]
  (% "%s %s %s"
     (, (get (getfile file) 0)
        (get (getfile file) 1)
        (if (get (getfile file) 2)
            "Dir"
            "File"))))

(defn sort [li] (.sort li) li)

(defn ls [DIR]
  (+ (sort (list (map getfile (get (next (os.walk DIR)) 1) )))
     (sort (list (map getfile (get (next (os.walk DIR)) 2) )))))

(defn getdir [dirname] (os.path.join BASEDIR dirname))

(setv app (Flask "__main__"))

(defn rmf [file]
  (setv currd (os.getcwd))
  (os.chdir (getdir (getpath file)))
  (setv file (getfilename file))
  (if (get (getfile file) 2)
      (os.rmdir file)
      (os.remove file))
  (os.chdir currd))

(defn getpage [dirname]
  (setv currd (os.getcwd))
  (os.chdir (getdir dirname))
  (setv ret (ls (getdir dirname)))
  (os.chdir currd)
  ret)

(defn getfilename [file]
  (get (.split file "/") -1))

(defn getpath [path]
  (if (= (len (.split path "/")) 1)
      ""
      (get (os.path.split path) 0)))

(with-decorator (app.route "/delete/<path:lepath>")
  (defn post-index [lepath]
    (rmf lepath)
    (apply render_template ["deleted.html"] {"item" lepath "redirto" (getpath lepath)})))

(with-decorator (app.route "/<path:lepath>")
  (defn get-index [lepath]
       (apply render_template ["page.html"] {"list" (getpage lepath) "path" (.join "" [lepath "/" ])})))

(with-decorator (app.route "/")
  (defn get-index2 []
       (apply render_template ["page.html"] {"list" (getpage ".") "toplevel" True "path" ""})))

(app.run)
