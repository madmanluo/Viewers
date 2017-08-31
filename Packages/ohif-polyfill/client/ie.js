/* jshint -W060 */

import { $ } from 'meteor/jquery';
import { absoluteUrl } from './lib/absoluteUrl';

const writeScript = fileName => {
    const src = absoluteUrl(`/packages/ohif_polyfill/public/js/${fileName}`);
    document.write(`<script src="${src}"><\/script>`);
};

// Check if browser is IE and add the polyfill scripts
if (navigator && /MSIE \d|Trident.*rv:/.test(navigator.userAgent)) {
    writeScript('svgxuse.min.js');
    writeScript('typedarray.min.js');

    window.addEventListener('click', event => {
        if (!window.SVGElementInstance || !(event.target instanceof SVGElementInstance)) return;
        $(event.target.correspondingUseElement).trigger('click');
    }, true);
}
