variable "kizuna" {
  default = "kizuna.router.kitashirakawa.dark-kuins.net."
}
variable "yukari" {
  default = "yukari.router.kitashirakawa.dark-kuins.net."
}
variable "hoshino" {
  default = "hoshino.compute.kitashirakawa.dark-kuins.net."
}


resource "google_dns_managed_zone" "rev-kitashirakawa" {
  name        = "rev-kitashirakawa"
  dns_name    = "184/29.220.50.192.in-addr.arpa."

  dnssec_config {
    state = "off"
  }
}

resource "google_dns_record_set" "hoshino" {
  name = "185.${google_dns_managed_zone.rev-kitashirakawa.dns_name}"
  type = "PTR"
  ttl  = 3600

  managed_zone = google_dns_managed_zone.rev-kitashirakawa.name

  rrdatas = [var.hoshino]
}

resource "google_dns_record_set" "yukari" {
  name = "189.${google_dns_managed_zone.rev-kitashirakawa.dns_name}"
  type = "PTR"
  ttl  = 3600

  managed_zone = google_dns_managed_zone.rev-kitashirakawa.name

  rrdatas = [var.yukari]
}

resource "google_dns_record_set" "kizuna" {
  name = "190.${google_dns_managed_zone.rev-kitashirakawa.dns_name}"
  type = "PTR"
  ttl  = 86400

  managed_zone = google_dns_managed_zone.rev-kitashirakawa.name

  rrdatas = [var.kizuna]
}

resource "google_dns_managed_zone" "rev-kitashirakawa6" {
  name        = "rev-kitashirakawa6"
  dns_name    = "7.a.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa."

  dnssec_config {
    state = "off"
  }
}

resource "google_dns_record_set" "kizuna6" {
  name = "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.${google_dns_managed_zone.rev-kitashirakawa6.dns_name}"
  type = "PTR"
  ttl  = 300

  managed_zone = google_dns_managed_zone.rev-kitashirakawa6.name

  rrdatas = [var.kizuna]
}

resource "google_dns_record_set" "hoshino6" {
  name = "4.1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.2.0.${google_dns_managed_zone.rev-kitashirakawa6.dns_name}"
  type = "PTR"
  ttl  = 300

  managed_zone = google_dns_managed_zone.rev-kitashirakawa6.name

  rrdatas = [var.hoshino]
}
