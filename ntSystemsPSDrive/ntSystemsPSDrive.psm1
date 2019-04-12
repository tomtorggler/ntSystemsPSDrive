using namespace Microsoft.PowerShell.SHiPS

try {
    $posts = Invoke-RestMethod https://ntsystems.it/api/v1/posts/ -ErrorAction SilentlyContinue | Select-Object -ExpandProperty items  
}
catch {
    Write-Warning "Could not connect to API: $_"
}

class Home : SHiPSDirectory
{
    
    Home() : base($this.GetType())
    {
    }

    # Optional method
    # Must define this c'tor if it can be used as a drive root, e.g.
    # new-psdrive -name abc -psprovider SHiPS -root module#type
    # Also it is good practice to define this c'tor so that you can create a drive and test it in isolation fashion.
    Home([string]$name): base($name)
    {
    }

    # Mandatory it gets called by SHiPS while a user does 'dir'
    [object[]] GetChildItem()
    {
        $obj =  @()

        Write-verbose "GetChildItem: Home"

        $obj += [ByType]::new("Category")
        $obj += [ByType]::new("Tags")
        $obj += [ByType]::new("Author")

        return $obj;
    }
}

class ByType : SHiPSDirectory
{
    [string]$TypeName = $null
    
    ByType () : base ("Posts by $TypeName")
    {
    }

    ByType ([string]$TypeName) : base ("Posts by $TypeName") { 
        $this.TypeName = $TypeName
    }

    [object[]] GetChildItem()
    {
        Write-verbose "GetChildItem: ByType $($this.TypeName)"

        $obj =  @()

        if($this.TypeName -eq "Tags"){
            $tags = $script:posts.tags | Select-Object -Unique
            $tags | ForEach-Object {
                $obj += [ntSystemsFolder]::new($_,($script:posts | Where-Object tags -contains $_ ))
            }
        } else {
            $script:posts | Group-Object -Property $this.TypeName | ForEach-Object {
                $obj += [ntSystemsFolder]::new($_.Name,$_.Group);
            }
        }
        return $obj;
    }
}

class ntSystemsItem : SHiPSLeaf
{
    [string]$title = $null;
    [string]$url = $null;
    [string]$category = $null;
    [string]$content = $null;

    ntSystemsItem() : base ($title) {

    }
    ntSystemsItem([string]$title) : base($title) {
        $this.title = $title
    }
    ntSystemsItem([string]$title, [string]$url, [string]$category, [string]$content) : base($title) {
        $this.title = $title
        $this.url = $url
        $this.category = $category
        $this.content = $content
    }

    [string] GetContent() {
        return $this.content
    }
}

class ntSystemsFolder : SHiPSDirectory
{
    [object]$items = $null

    ntSystemsFolder() : base($this.GetType()) {

    }

    ntSystemsFolder([string]$name, [object]$items) : base($name) {
        $this.items = $items
    }

    [object[]] GetChildItem()
    {
        $obj =  @()

        Write-verbose "you run getchilditem in ntsystemsfolder [$($this.name)]"

        $this.items | ForEach-Object {
            Write-Verbose "GetChildItem: ntSystemsFolder"
            $obj += [ntSystemsItem]::new($_.title, $_.url, $_.category, $_.content)
        }

        return $obj;
    }

}
