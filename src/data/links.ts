import {faGithub, faTelegram, faXTwitter, type IconDefinition} from "@fortawesome/free-brands-svg-icons"
import {faEnvelope, faFile} from "@fortawesome/free-solid-svg-icons"
import {LOOKING_FOR_JOB} from "astro:env/server"

export type Link = {
  title: string
  href: string
  icon: IconDefinition
}

const links: Link[] = [
  {title: "X.com", href: "https://x.com/mxseev", icon: faXTwitter},
  {title: "Github", href: "https://github.com/mxseev", icon: faGithub},
  {title: "Telegram", href: "https://t.me/mxseev", icon: faTelegram},
  {title: "Email", href: "mailto:mxseev@gmail.com", icon: faEnvelope}
]

if (LOOKING_FOR_JOB) {
  links.push({title: "CV", href: "/cv", icon: faFile})
}

export {links}
