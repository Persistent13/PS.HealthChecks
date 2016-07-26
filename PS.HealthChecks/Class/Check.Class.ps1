class Check
{
    [String]$Name
    [String]$Tag
    [UInt32]$Timeout
    [UInt32]$Grace
    [Uri]$PingURL
    [Uint32]$PingCount
    [Nullable[DateTime]]$LastPing
    [Nullable[DateTime]]$NextPing

    Check()
    {
        $this.Name
        $this.Tag
        $this.Timeout
        $this.Grace
        $this.PingURL
        $this.PingCount
        $this.LastPing
        $this.NextPing
    }
    Check([String]$Name,[String]$Tag,[UInt32]$Timeout,[UInt32]$Grace,[Uri]$PingURL,[Uint32]$PingCount,[Nullable[DateTime]]$LastPing,[Nullable[DateTime]]$NextPing)
    {
        $this.Name = $Name
        $this.Tag = $Tag
        $this.Timeout = $Timeout
        $this.Grace = $Grace
        $this.PingURL = $PingURL
        $this.PingCount = $PingCount
        $this.LastPing = $LastPing
        $this.NextPing = $NextPing
    }
}