using namespace Microsoft.PowerShell.SHiPS

try {
    # get all posts from json api 
    $script:posts = Invoke-RestMethod https://ntsystems.it/api/v1/posts/ -ErrorAction Stop | Select-Object -ExpandProperty items  
}
catch {
    Write-Warning "Could not connect to API: $_"
}

class Home : SHiPSDirectory {

    # define home entry point. #home should be used as root when creating the psdrive
    # when GetChildItem() is called, return folders with useful views
    
    Home() : base($this.GetType()) {
    }

    Home([string]$name): base($name) {
    }

    [object[]] GetChildItem() {
        Write-Verbose "GetChildItem: Home"

        $obj = @()
        $obj += [ntSystemsType]::new("Category")
        $obj += [ntSystemsType]::new("Tags")
        $obj += [ntSystemsType]::new("Author")
        $obj += [ntSystemsType]::new("Language")
        return $obj
    }
}

class ntSystemsType : SHiPSDirectory {

    # gets called by GetChildItem in home and returns folders as requested  

    [string]$TypeName = $null
    
    ntSystemsType () : base ("Posts by $TypeName") {
    }

    ntSystemsType ([string]$TypeName) : base ("Posts by $TypeName") { 
        $this.TypeName = $TypeName
    }

    [object[]] GetChildItem() {
        Write-Verbose "GetChildItem: ntSystemsType $($this.TypeName)"
        $obj = @()
        if ($this.TypeName -eq "Tags") {
            $tags = $script:posts.tags | Select-Object -Unique
            $tags | ForEach-Object {
                $obj += [ntSystemsFolder]::new($_, ($script:posts | Where-Object tags -contains $_ ))
            }
        }
        else {
            $script:posts | Group-Object -Property $this.TypeName | ForEach-Object {
                $obj += [ntSystemsFolder]::new($_.Name, $_.Group);
            }
        }
        return $obj;
    }
}

class ntSystemsItem : SHiPSLeaf {

    # define post (leaf) items

    [string]$title = $null
    [string]$url = $null
    [string]$category = $null
    [string]$tags = $null
    [string]$content = $null
    [string]$language = $null

    ntSystemsItem() : base ($title) {
    }

    ntSystemsItem([string]$title) : base($title) {
        $this.title = $title
    }

    ntSystemsItem([string]$title, [object]$item) : base($title) {
        $this.title = $title
        $this.url = $item.url
        $this.category = $item.category
        $this.content = $item.content
        $this.tags = $item.tags
        $this.language = $item.language
    }

    # define method for Get-Content
    [string] GetContent() {
        Write-Verbose "GetContent ntSystemsItem"
        return $this.content
    }
}

class ntSystemsFolder : SHiPSDirectory {

    # gets called by GetChildItem in ntSystemsType and returns folders containing post items

    [object]$items = $null

    ntSystemsFolder() : base($this.GetType()) {
    }

    ntSystemsFolder([string]$name, [object]$items) : base($name) {
        $this.items = $items
    }

    [object[]] GetChildItem() {
        Write-Verbose "GetChildItem: ntSystemsFolder $($this.Name)"
        $obj = @()
        $this.items | ForEach-Object {
            Write-Verbose "GetChildItem: ntSystemsFolder"
            $obj += [ntSystemsItem]::new($_.title, $_)
        }
        return $obj;
    }
}

function New-ntSystemsPSDrive {
    [cmdletbinding()]
    param (
        [string]
        $Name = "ntSystems",
        [string]
        $Root = "Home"
    )
    try{
        New-PSDrive -Name $Name -PSProvider SHiPS -Root "ntSystemsPSDrive#$Root" -Scope Global -ErrorAction Stop
    }
    catch {
        Write-Warning "Unable to create PSDrive: $_"    
    }    
}