using System;

namespace Healthchecks
{
    public class Check
    {
        public string Name { get; set; }
        public string Tag { get; set; }
        public UInt32 Timeout { get; set; }
        public UInt32 Grace { get; set; }
        public Uri PingUrl { get; set; }
        public UInt32 PingCount { get; set; }
        public Nullable<DateTime> LastPingDate { get; set; }
        public Nullable<DateTime> NextPingDate { get; set; }

        public Check() { }
        public Check(
            string Name, string Tag, UInt32 Timeout, UInt32 Grace, Uri PingUrl,
            UInt32 PingCount, DateTime? LastPingDate, DateTime? NextPingDate
        )
        {
            this.Name = Name;
            this.Tag = Tag;
            this.Timeout = Timeout;
            this.Grace = Grace;
            this.PingUrl = PingUrl;
            this.PingCount = PingCount;
            this.LastPingDate = LastPingDate;
            this.NextPingDate = NextPingDate;
        }
    }
}
