import {Button, Input, FlipperPlugin, FlexColumn, styled, Text} from 'flipper';

type ThemeResponse = {
  jsonEntry: {},
};

type State = {
  jsonEntry: {},
  prompt: '',
};

const Container = styled(FlexColumn)({
  alignItems: 'center',
  justifyContent: 'space-around',
  padding: 20,
});

export default class extends FlipperPlugin<*, State> {

  state = {
    jsonEntry: {},
    prompt: '',
  };

  sendTheme() {
    this.client.call('updateDynamicTheme', {sentJson: this.state.jsonEntry}).then((res: ThemeResponse) => {
      this.setState({
        prompt: "Theme sent to the device"
       });
    });
  }

  getCurrentAppTheme() {
    this.client.call('getCurrentTheme', this.state.jsonEntry).then((res: ThemeResponse) => {
      // console.log(res.theme);
      this.setState({
        jsonEntry: res.theme,
        prompt: "Theme received from the device"
       });
    });
  }

  loadThemeFromFile() {
    //will need to base 64 decode,if encoded, and then display it
  }

  exportThemeToFile() {
    //will need to base 64 decode,if encoded, and then display it
  }

  render() {
    // this.getCurrentAppTheme();
          
    return (
      <Container>
        <Text>Theme Info</Text>
        <textarea type="text" rows="50" cols="50"
          value = {this.state.jsonEntry} onChange={event => {
            this.setState({jsonEntry: event.target.value});
          }}
        />
        <Button onClick={this.sendTheme.bind(this)}>Send Theme to App</Button>
        <Button onClick={this.getCurrentAppTheme.bind(this)}>Import Theme from App</Button>
        <Button onClick={this.loadThemeFromFile.bind(this)}>Import Theme from File</Button>
        <Button onClick={this.exportThemeToFile.bind(this)}>Export Theme to File</Button>
        <br /><br />
        <Text ref="prompt">{this.state.prompt}</Text>
      </Container>
    );
  }
}