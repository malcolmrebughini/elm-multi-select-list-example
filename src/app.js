import Elm from './Main.elm';


const options = new Array(6500)
  .fill('Test Value')
  .map((v, i) => ({ id: i, name: `${v} ${i}` }));

const app = Elm.Main.fullscreen({
  options,
  selectedOptions: [],
  hasNoneCheckbox: false,
  includeNoneUnknown: false,
  containerHeight: 336,
  elementHeight: 20,
});

app.ports.getValuesReturn.subscribe((values) => {
  console.log(values);
});

const button = document.createElement('button');
button.addEventListener('click', () => app.ports.getValues.send(true));
button.textContent = 'Get Values';

document.body.appendChild(button);