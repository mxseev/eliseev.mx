import customMedia from "postcss-custom-media"
import nesting from "postcss-nesting"
import normalize from "postcss-normalize"
import globalData from "@csstools/postcss-global-data"
import mediaMinmax from "@csstools/postcss-media-minmax"
import customUnit from "postcss-custom-unit"

const STEP_BASE_VALUE = 0.4

export default {
  plugins: [
    globalData({files: [
      "./src/styles/variables.css",
      "./src/styles/media.css"
    ]}),
    mediaMinmax(),
    customMedia(),
    customUnit({
      units: [{
        from: "step",
        convert: value => value * STEP_BASE_VALUE + "rem"
      }]
    }),
    nesting(),
    normalize()
  ]
}
