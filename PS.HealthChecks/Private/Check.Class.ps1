class Check
{
    [String]$Name
    [String]$Tag
    [UInt32]$Timeout
    [UInt32]$Grace
    [Uri]$PingURL
    [Uint32]$PingCount
    [DateTime]$LastPing
    [DateTime]$NextPing
}