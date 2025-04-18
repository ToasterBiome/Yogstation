import { createSearch } from 'common/string';
import { multiline } from 'common/string';
import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Divider, Flex, Icon, Input, Section } from '../components';
import { Window } from '../layouts';

const PATTERN_NUMBER = / \(([0-9]+)\)$/;

const searchFor = searchText => createSearch(searchText, thing => thing.name);

const compareString = (a, b) => a < b ? -1 : a > b;

const compareNumberedText = (a, b) => {
  const aName = a.name;
  const bName = b.name;

  // Check if aName and bName are the same except for a number at the end
  // e.g. Medibot (2) and Medibot (3)
  const aNumberMatch = aName.match(PATTERN_NUMBER);
  const bNumberMatch = bName.match(PATTERN_NUMBER);

  if (aNumberMatch
    && bNumberMatch
    && aName.replace(PATTERN_NUMBER, "") === bName.replace(PATTERN_NUMBER, "")
  ) {
    const aNumber = parseInt(aNumberMatch[1], 10);
    const bNumber = parseInt(bNumberMatch[1], 10);

    return aNumber - bNumber;
  }

  return compareString(aName, bName);
};

const OrbitedButton = (props, context) => {
  const { act } = useBackend(context);
  const { color, thing } = props;

  return (
    <Button
      color={color}
      onClick={() => act("orbit", {
        ref: thing.ref,
      })}>
      {thing.name}
      {thing.orbiters && (
        <Box inline ml={1}>
          {"("}{thing.orbiters}{" "}
          <Box
            as="img"
            src={resolveAsset('ghost.png')}
            opacity={0.7} />
          {")"}
        </Box>
      )}
    </Button>
  );
};

const BasicSection = (props, context) => {
  const { act } = useBackend(context);
  const { searchText, source, title, color } = props;
  const things = source.filter(searchFor(searchText));
  things.sort(compareNumberedText);
  return source.length > 0 && (
    <Section title={`${title} - (${source.length})`}>
      {things.map(thing => (
        <OrbitedButton
          key={thing.name}
          thing={thing}
          color={color}
        />
      ))}
    </Section>
  );
};

export const Orbit = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    alive,
    antagonists,
    auto_observe,
    dead,
    ghosts,
    is_admin,
    misc,
    npcs,
  } = data;

  const [searchText, setSearchText] = useLocalState(context, "searchText", "");

  const collatedAntagonists = {};
  for (const antagonist of antagonists) {
    if (collatedAntagonists[antagonist.antag] === undefined) {
      collatedAntagonists[antagonist.antag] = [];
    }
    collatedAntagonists[antagonist.antag].push(antagonist);
  }

  const sortedAntagonists = Object.entries(collatedAntagonists);
  sortedAntagonists.sort((a, b) => {
    return compareString(a[0], b[0]);
  });

  const orbitMostRelevant = searchText => {
    for (const source of [
      sortedAntagonists.map(([_, antags]) => antags),
      alive, ghosts, dead, npcs, misc,
    ]) {
      const member = source
        .filter(searchFor(searchText))
        .sort(compareNumberedText)[0];
      if (member !== undefined) {
        act("orbit", { ref: member.ref });
        break;
      }
    }
  };

  return (
    <Window
      title="Orbit"
      width={350}
      height={700}>
      <Window.Content scrollable>
        <Section>
          <Flex>
            <Flex.Item>
              <Icon
                name="search"
                mr={1} />
            </Flex.Item>
            <Flex.Item grow={1}>
              <Input
                placeholder="Search..."
                autoFocus
                fluid
                value={searchText}
                onInput={(_, value) => setSearchText(value)}
                onEnter={(_, value) => orbitMostRelevant(value)} />
            </Flex.Item>
            <Flex.Item>
              <Divider vertical />
            </Flex.Item>
            <Flex.Item>
              <Button
                inline
                color="transparent"
                tooltip={multiline`Toggle Auto-Observe. When active, you'll
                see the UI / full inventory of whoever you're orbiting. Neat!`}
                tooltipPosition="bottom-start"
                selected={auto_observe}
                icon={auto_observe ? "toggle-on" : "toggle-off"}
                onClick={() => act("toggle_observe")} />
              <Button
                inline
                color="transparent"
                tooltip="Refresh"
                tooltipPosition="bottom-start"
                icon="sync-alt"
                onClick={() => act("refresh")} />
            </Flex.Item>
          </Flex>
        </Section>
        {antagonists.length > 0 && (
          <Section title={is_admin ? "Antagonists" : "Ghost-Visible Antagonists"}>
            {sortedAntagonists.map(([name, antags]) => (
              <BasicSection
                key={name}
                title={name}
                source={antags}
                searchText={searchText}
                color="bad"
                level={2}
              />
            ))}
          </Section>
        )}

        <BasicSection
          title="Alive"
          source={alive}
          searchText={searchText}
          color="good"
        />

        <BasicSection
          title="Ghosts"
          source={ghosts}
          searchText={searchText}
          color="grey"
        />

        <BasicSection
          title="Dead"
          source={dead}
          searchText={searchText}
        />

        <BasicSection
          title="NPCs"
          source={npcs}
          searchText={searchText}
        />

        <BasicSection
          title="Misc"
          source={misc}
          searchText={searchText}
        />
      </Window.Content>
    </Window>
  );
};
