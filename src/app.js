import Elm from './LongList/Main.elm';


const options = new Array(2000)
    .fill('Test Value')
    .map((v, i) => {
        return { id: i, name: `${v} ${i}` };
    });

const app = Elm.LongList.fullscreen({
    options,
    selectedOptions: [],
    hasNoneCheckbox: false,
    includeNoneUnknown: false,
});
