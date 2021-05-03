import * as acorn from 'acorn';
import estraverse from 'estraverse';
import _ from 'lodash';

const log = console.log;
// const log = () => {};

const uniq = (list) => _.uniqBy(list, 'url');

/** @typedef {import("./index").Video} Video */

const findVideoSectionsInModule = (body) => {
  const variables = body.filter((node) => node.type === 'VariableDeclaration');
  for (const variable of variables) {
    let videosNodes;
    estraverse.traverse(variable, {
      fallback: 'iteration',
      enter: function (node, parent) {
        if (node.type == 'VariableDeclaration') {
          const arrayDeclarations = node.declarations.filter((declaration) => {
            return declaration.init?.type === 'ArrayExpression';
          });
          if (arrayDeclarations.length === 0) {
            return this.skip();
          }
          const videosNodesProbably = arrayDeclarations.filter(
            (arrayDeclaration) => {
              const init = arrayDeclaration.init;
              if (init?.type !== 'ArrayExpression') {
                return false;
              }
              if (init.elements.length === 0) {
                return false;
              }
              let looksOkay = false;
              const hasProperty = (properties, propertyName) => {
                return (
                  properties.find((property) => {
                    if (property.type !== 'Property') {
                      return false;
                    }
                    if (property.key.type !== 'Identifier') {
                      return false;
                    }
                    return property.key.name === propertyName;
                  }) != null
                );
              };
              for (const element of init.elements) {
                if (element == null || element.type !== 'ObjectExpression') {
                  looksOkay = false;
                  continue;
                }
                const hasProperties =
                  hasProperty(element.properties, 'id') &&
                  hasProperty(element.properties, 'url') &&
                  hasProperty(element.properties, 'location') &&
                  hasProperty(element.properties, 'author');
                looksOkay = looksOkay || hasProperties;
              }
              return looksOkay;
            }
          );

          if (videosNodesProbably.length > 0) {
            log(
              `found multiple (${videosNodesProbably.length}) probably nodes, skipping`
            );

            videosNodes = videosNodesProbably;
          }
        } else {
          this.skip();
        }
      },
    });

    if (videosNodes != null) {
      return videosNodes
        .map((videosNode) => {
          const init = videosNode.init;
          if (init != null && init.type === 'ArrayExpression') {
            return init;
          }
        })
        .filter((v) => v != null);
    }
  }
};

const extractFrom = (source) => {
  const ast = acorn.parse(source, { ecmaVersion: 2018 });

  if (ast.type !== 'Program') {
    throw new Error('root node is not a Program, no way to proceed?');
  }

  const body = ast.body;

  const expression = body[0];
  if (expression?.type !== 'ExpressionStatement') {
    throw new Error('expected expression to kick off, no way to proceed?');
  }

  const call = expression.expression;
  if (call.type !== 'CallExpression' || call.arguments.length != 1) {
    throw new Error('unexpected node to kick off, no way to proceed?');
  }

  const argument = call.arguments[0];
  if (argument.type !== 'ArrayExpression' || argument.elements.length !== 3) {
    throw new Error('unexpected node to kick off, no way to proceed?');
  }

  const element = argument.elements[1];
  if (element?.type != 'ObjectExpression') {
    throw new Error('unexpected node to kick off, no way to proceed?');
  }

  const properties = element.properties;
  const modules = properties
    .map((property) => {
      if (property.type !== 'Property') {
        return;
      }

      let key;

      if (property.key.type === 'Literal') {
        key = property.key.value?.toString();
      } else if (property.key.type === 'Identifier') {
        key = property.key.name;
      }

      if (key == null) {
        return;
      }

      return {
        key,
        value: property.value,
      };
    })
    .map((kv) => {
      if (kv?.value.type !== 'FunctionExpression') {
        return;
      }

      const body = kv.value.body;

      if (body.type !== 'BlockStatement') {
        return;
      }

      return {
        ...kv,
        value: body.body,
      };
    })
    .filter((v) => v !== undefined);

  for (const module of modules) {
    if (module == null) {
      continue;
    }

    const body = module.value;
    const results = findVideoSectionsInModule(body);

    if (Array.isArray(results) && results.length > 0) {
      log(`found values (${results.length}) via key: ${module.key}`);

      const valids = results.map((result) => {
        const start = result.start;
        const end = result.end;
        const js = source.substring(start, end);
        const list = eval(js);

        // we've only found that we have _some_ valid videos, so let's filter out anything that looks actually invalid
        const valid = list.filter(
          (video) =>
            typeof video.id === 'number' &&
            typeof video.url === 'string' &&
            typeof video.location === 'string' &&
            typeof video.author === 'string'
        );

        return uniq(valid);
      });

      if (valids.length === 1) {
        log(`returning video count: ${valids[0].length}`);
        return _.sortBy(valids[0], 'url');
      } else if (valids.length > 1) {
        // there's a difference between arrays where "logged in" vs "logged out",
        // but it doesn't seem like it's actually being used yet. I think it's just
        // incentive, not an actual functional difference.
        //
        // so, we just merge the arrays, and pull out any unique nodes, showing all
        // of everything that we can.
        const joined = uniq([].concat.apply([], valids));
        log(`returning merged video count: ${joined.length}`);

        return _.sortBy(joined, 'url');
      }
    } else {
      log('no match found in module: ' + module.key);
    }
  }

  log('⚠️ no result found!');
  return [];
};

/**
 * @param {string} source
 * @returns {Video[]|null}
 */
const resolve = (source) => {
  if (source == null) {
    return null;
  }

  const sources = extractFrom(source);

  return sources;
};

export default resolve;
