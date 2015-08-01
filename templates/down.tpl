<!DOCTYPE html>

<head>
    <title>&lt;Down&gt;</title>
    <base href="{{doc_root}}">
    <meta charset="utf-8">
    <meta id="meta" name="viewport" content="width=device-width; initial-scale=1.0">

    <link rel="stylesheet" type="text/css" href="css/min_stylesheet.css">
    <link rel="shortcut icon" type="image/png" href="img/logo_small.png">

    % from os import listdir
    % from os.path import isfile, join
</head>

<body>
    <div id="center_container">
        <div class="text">Download.</div>
        <table id="files">
            <tbody>
        <%
         onlyfiles = [ f for f in listdir(join( down_root, 'var/down/')) if isfile(join( down_root, 'var/down/',f)) ]
         for item in onlyfiles:
        %>
            <tr>
                <td class="file"><a href="file/{{item}}">{{item}}</a></td>
                <td class="del"><a href="delete/{{item}}">[delete]</a></td>
            </tr>
        % end
            </tbody>
        </table>

        <br/><br/>
        <div class="text">
            Upload.
        </div>
        <form action="upload" method="post" enctype="multipart/form-data" id="uploadForm">
            <input name="upload" type="file" id="fileA" onchange="fileChange();" multiple/>
            <br /><br />
            <input name="action" value="Upload" type="button" onclick="uploadFile();" />
            <input name="abort" value="Cancel" type="button" onclick="uploadAbort();" />
        </form>
        <div>
            <div id="fileName"></div>
            <div id="fileSize"></div>
            <div id="fileType"></div>
            <progress id="progress" style="margin-top:10px"></progress> <span id="percent"></span>
        </div>
    </div>
</body>

<script>
    document.getElementById("progress").value = 0;
    document.getElementById("percent").innerHTML = "0%";

    function fileChange()
    {
        var fileList = document.getElementById("fileA").files;
        var file = fileList[0];
        if(!file)
            return;
        document.getElementById("fileName").innerHTML = 'Filename: ' + file.name;
        document.getElementById("fileSize").innerHTML = 'Size: ' + file.size + ' B';
        document.getElementById("fileType").innerHTML = 'Type: ' + file.type;
        document.getElementById("progress").value = 0;
        document.getElementById("percent").innerHTML = "0%";
    }
    var xhr = null;
     
    function uploadFile()
    {
        var files = document.getElementById("fileA").files;
        var formData = new FormData();

        // File objects
        for( i = 0; i < files.length; i++ ) {
            var file = files[i];

            if(!file) {
                return;
            }

            // FormData object for POST request, will 'carry' the file(s)
            formData.append("upload", file);
        }

        // XMLHttpRequest object
        xhr = new XMLHttpRequest();

        var progressBar = document.getElementById("progress");
        progressBar.value = 0;
        progressBar.max = 100;


        xhr.onerror = function(e) {
            document.getElementById("fileName").innerHTML = 'Error!';
        };

        xhr.onload = function(e) {
            if( xhr.status != 200 ) {
                document.getElementById("fileName").innerHTML = 'Error!';
            }
            else {
                document.getElementById("percent").innerHTML = "100%";
                progressBar.value = progressBar.max;

                document.getElementById("uploadForm").reset();

                document.getElementById("fileName").innerHTML = 'Success';
                document.getElementById("fileSize").innerHTML = '';
                document.getElementById("fileType").innerHTML = '';
                location.reload();
            }
        };

        xhr.upload.onprogress = function(e) {
            var p = Math.round(100 / e.total * e.loaded);
            progressBar.value = p;            
            document.getElementById("percent").innerHTML = p + "%";
        };

        xhr.open("POST", "upload"); // method: POST, url: ./upload
        xhr.send(formData);

    }

    function uploadAbort() {
        if(xhr instanceof XMLHttpRequest) {
            xhr.abort();
            document.getElementById("progress").value = 0;
            document.getElementById("percent").innerHTML = "0%";
        }
    }
</script>
